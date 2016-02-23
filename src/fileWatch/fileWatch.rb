require 'rb-inotify'
module FileWatch
    # http://blog.honeybadger.io/ruby-custom-exceptions/

    class FileNotFound < StandardError
    end
    class FileNotDestroyed < StandardError
    end
    class ActionNotPerformed < StandardError
    end

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
            raise TypeError, "Files must be present as a comma-separated string or a list of strings."
        end
        return files
    end

    def check_duration(duration)
	    #http://rubylearning.com/satishtalim/ruby_exceptions.html
        raise TypeError, "Duration must be a Numeric value greater than or equal to 0." unless
            ((duration.is_a? Numeric) && (duration >= 0))
        return duration
    end

    def preconditions_check(args, &main_action)
        duration = args[0]
        files = args[1]
        raise ArgumentError, "Action required." unless block_given?
        case duration
        when Numeric
            files = format_and_check_files(files)
            duration = check_duration(duration)
        when Array, String
            files = format_and_check_files(duration)
            duration = 0
        else
            raise ArgumentError, "Action"
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
