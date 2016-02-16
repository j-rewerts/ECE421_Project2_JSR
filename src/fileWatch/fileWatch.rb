require 'rb-inotify'
module FileWatch

    def FileWatchCreation(duration, files, &action)
        # create_thread = Thread.new do
        # end
        # create_thread.priority = -2;
    end

    def FileWatchAlter(duration, files, &action)
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
    end

    def FileWatchDestroy(duration, files, &action)
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
    end

end
