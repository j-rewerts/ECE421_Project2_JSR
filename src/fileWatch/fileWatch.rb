require 'rb-inotify'
module FileWatch
    # http://blog.honeybadger.io/ruby-custom-exceptions/

    class FileNotFound < StandardError
    end
    class FileNotDestroyed < StandardError
    end
    class ActionNotPerformed < StandardError
    end

    @@files_arg_requirements = "Files must be present as a comma-separated string ('file1.txt,dir2,...') or a list of strings (['dir1','file2.txt',...])."
    @@duration_arg_requirements = "When provided, Duration is in seconds and must be a Numeric value greater than or equal to 0."

    def format_and_check_files(files)
        case files
        when Array
            raise ArgumentError, "There must be at least one file to watch." if files.empty?
            files.each {|file| raise TypeError, "Filename must be a string." unless file.is_a? String}
        when String
            #files.include? "," ? files = files.split(",") : files = [files]
            if (files.include? ",")
                files = files.split(",")
            else
                files = [files]
            end
        else
            raise TypeError, @@files_arg_requirements
        end
        return files
    end

    def check_duration(duration)
	    #http://rubylearning.com/satishtalim/ruby_exceptions.html
        raise TypeError, @@duration_arg_requirements unless
            ((duration.is_a? Numeric) && (duration >= 0))
        return duration
    end

    def preconditions_check(args, &main_action)
        raise ArgumentError, "Incorrent number of arguments. \n"\
                             "Expected parameters are: \n" \
                             "(1.) Duration: #{@@duration_arg_requirements} \n"\
                             "(2.) Files: #{@@files_arg_requirements} \n"\
                             "and action." unless (args.size == 1 or args.size == 2)
        raise ArgumentError, "Action required." unless block_given?

        if args.size == 1
            duration = 0
            files = format_and_check_files(args[0])
        else
            duration = check_duration(args[0])
            files = format_and_check_files(args[1])
        end
        return [duration,files]
    end

    def FileWatchCreation(*args, &main_action)
        duration, files = preconditions_check(args, &main_action)

        postcondition = false
        action = Proc.new {
            sleep(duration)
            main_action.call
            postcondition = true
        }

        files.each { |file|
            create_thread = Thread.new do
                while ( postcondition == false)
                    # http://www.gethourglass.com/blog/ruby-check-if-file-exists.html
                    action.call if File.exist?(file)
                end
            end
            create_thread.priority = -1
        }
    end

    def FileWatchAlter(*args, &main_action)
        duration, files = preconditions_check(args, &main_action)
        files.each {|file|
            raise FileNotFound, "File must exist." unless File.exist?(file)
        }

        begin
            watcher = INotify::Notifier.new
            postcondition = false
            action = Proc.new {
                sleep(duration)
                main_action.call
                postcondition = true
            }
            files.each {
                |file| watcher.watch(file, :modify, :create, :attrib, :delete, :move_self, &action)
            }
            alter_thread = Thread.new do
                watcher.run
                raise ActionNotPerformed if postcondition == false
            end
            alter_thread.priority = -1

        rescue Exception => e
            case e
            when Errno::ENOENT
                raise FileNotFound
            else
                raise e
            end
        end
    end

    def FileWatchDestroy(*args, &main_action)
        duration, files = preconditions_check(args, &main_action)
        files.each {|file|
            raise FileNotFound, "File must exist." unless File.exist?(file)
        }

        begin
            watcher = INotify::Notifier.new
            postcondition = false
            action = Proc.new {
                sleep(duration)
                main_action.call
                postcondition = true
            }
            files.each {
                |file| watcher.watch(file, :delete_self, &action)
            }

            destory_thread = Thread.new do
                watcher.run
                raise ActionNotPerformed if postcondition == false
                files.each {|file|
                    raise FileNotDestroyed, "File still exists." unless !(File.exist?(file))
                }
            end
            destory_thread.priority = -1

        rescue Exception => e
            case e
            when Errno::ENOENT
                raise FileNotFound
            else
                raise e
            end
        end
    end
end
