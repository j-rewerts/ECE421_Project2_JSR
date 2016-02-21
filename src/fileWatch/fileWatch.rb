require 'rb-inotify'
module FileWatch
    # http://blog.honeybadger.io/ruby-custom-exceptions/

    class FileNotFound < StandardError
    end
    class FileNotDestroyed < StandardError
    end
    class ActionNotPerformed < StandardError
    end

    def is_a_file?(name)
        false unless name.include? "."
        true
    end

    def format_and_check_files(files)
        case files
        when Array
            files.each {|file| raise TypeError unless file.is_a? String}
        when String
            #files.include? "," ? files = files.split(",") : files = [files]
            if (files.include? ",")
                files = files.split(",")
            else
                files = [files]
            end
        else
            raise TypeError
        end
        return files
    end

    def check_duration(duration)
	#http://rubylearning.com/satishtalim/ruby_exceptions.html
        raise TypeError, "duration must be a Numeric value greater than or equal to 0." unless
            ((duration.is_a? Numeric) && (duration >= 0))
    end

    def FileWatchCreation(duration, files, &main_action)
        check_duration(duration)
        files = format_and_check_files(files)

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

    def FileWatchAlter(duration, files, &main_action)
        check_duration(duration)
        files = format_and_check_files(files)
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

    def FileWatchDestroy(duration, files, &main_action)
        check_duration(duration)
        files = format_and_check_files(files)
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
            postcondition = false
            action = Proc.new {
                sleep(duration)
                main_action.call
                postcondition = true
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
