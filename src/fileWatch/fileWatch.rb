require 'rb-inotify'
module FileWatch
    # http://blog.honeybadger.io/ruby-custom-exceptions/
    class FileNotFound < StandardError
    end
    def is_a_file?(name)
        false unless name.include? "."
        true
    end
    def FileWatchCreation(duration, files, &action)
        files_on_system = []
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

        create_thread = Thread.new do
            while ( files.any? )
                # http://stackoverflow.com/questions/3260686/how-can-i-use-arraydelete-while-iterating-over-the-array
                files.delete_if do |file|
                    if is_a_file?(file)
                        files_on_system = Dir.glob("**/*")
                    else
                        files_on_system = Dir.glob("**/*/")
                    end
                    if files_on_system.include? file
                        #act_thread = Thread.new do
                        action.call
                        #end
                        true
                    end
                end
            end
        end
        create_thread.priority = -1;
    end

    def FileWatchAlter(duration, files, &action)
        begin
            watcher = INotify::Notifier.new
            case files
            when Array
                files.each {
                    |file| watcher.watch(file, :modify, &action)
                }
            when String
                watcher.watch(files, :modify, &action)
            end
            alter_thread = Thread.new do
                watcher.run
            end

        rescue Exception => e
            case e
            when Errno::ENOENT
                raise FileNotFound
            end
        end
        sleep(1)
    end

    def FileWatchDestroy(duration, files, &action)
        begin
            watcher = INotify::Notifier.new
            case files
            when Array
                files.each {
                    |file| watcher.watch(file, :delete, &action)
                }
            when String
                watcher.watch(files, :delete, &action)
            end
            destory_thread = Thread.new do
                watcher.run
            end

        rescue Exception => e
            case e
            when Errno::ENOENT
                raise FileNotFound
            end
        end
        sleep(1)
    end

end
