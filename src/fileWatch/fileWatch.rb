require 'rb-inotify'
module FileWatch
    # http://blog.honeybadger.io/ruby-custom-exceptions/
    class FileNotFound < StandardError
    end
    def is_a_file?(name)
        false unless name.include? "."
        true
    end
    def FileWatchCreation(duration, files, &main_action)
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
        postcondition = false
        action = Proc.new {
            sleep(duration)
            main_action.call
            postcondition = true
        }

        files.each { |file|
            create_thread = Thread.new do
                while ( postcondition == false)
                    action.call if File.exist?(file)
                end
            end
            create_thread.priority = -1
        }
    end

    def FileWatchAlter(duration, files, &main_action)
        postcondition = false
        action = Proc.new {
            sleep(duration)
            main_action.call
            postcondition = true
        }
        begin
            watcher = INotify::Notifier.new
            case files
            when Array
                files.each {
                    |file| watcher.watch(file, :modify, :create, :attrb, :delete, :move_self, &action)
                }
            when String
                watcher.watch(files, :modify, :create, :attrib, :delete, :move_self, &action)
            end
            alter_thread = Thread.new do
                watcher.run
                raise StandardError if postcondition == false
            end
            alter_thread.priority = -1

        rescue Exception => e
            case e
            when Errno::ENOENT
                raise FileNotFound
            end
        end
    end

    def FileWatchDestroy(duration, files, &main_action)
        postcondition = false
        action = Proc.new {
            sleep(duration)
            main_action.call
            postcondition = true
        }

        begin
            watcher = INotify::Notifier.new
            case files
            when Array
                files.each {
                    |file| watcher.watch(file, :delete_self, &action)
                }
            when String
                watcher.watch(files, :delete_self, &action)
            end
            destory_thread = Thread.new do
                watcher.run
                raise StandardError if postcondition == false
            end
            destory_thread.priority = -1

        rescue Exception => e
            case e
            when Errno::ENOENT
                raise FileNotFound
            end
        end
    end

end
