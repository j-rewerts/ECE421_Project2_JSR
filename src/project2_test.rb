require "test/unit"
require "stringio"
require_relative "fileWatch/fileWatch.rb"
include FileWatch
class Project2Test < Test::Unit::TestCase

    def test_message_bad_input
        message = "message"

        out = capture_stdout do
            system("ruby ./message/message_driver.rb 0 " + message)
        end

        sleep(5)
        assert_equal(out.string, message)
    end

    def test_message_overflow

    end


    def test_pipe_watch_destroy_no_timing
        destoryed = false
        pipeName = "test_pipe_watch_destruction"
        `rm -rf #{pipeName}`
        `mkfifo #{pipeName}`
        assert_equal($?.exitstatus, 0, "couldn't create pipe")
        duration = 0
        FileWatchDestroy(
            duration,
            pipeName) {destoryed = true}
        assert(!destoryed)
        `rm -rf #{pipeName}`
        assert_equal($?.exitstatus, 0, "couldn't remove pipe")
        assert(destoryed)
    end

    def test_dir_watch_destroy_no_timing
        destoryed = false
        dirName = "test_dir_watch_destruction"
        `rm -rf #{dirName}`
        `mkdir #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't create dir")
        duration = 0
        FileWatchDestroy(
            duration,
            dirName) {destoryed = true}
        assert(!destoryed)
        `rm -rf #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't remove dir")
        assert(destoryed)
    end


    def test_pipe_watch_creation_no_timing
        created = false
        pipeName = "test_pipe_watch_creation"
        duration = 0
        FileWatchCreation(
            duration,
            pipeName) {created = true}
        assert(!created)
        `rm -rf #{pipeName}`
        `mkfifo #{pipeName}`
        assert_equal($?.exitstatus, 0, "couldn't create pipe")
        assert(created)
        `rm -rf #{pipeName}`
        assert_equal($?.exitstatus, 0, "couldn't remove pipe")
    end

    def test_dir_watch_creation_no_timing
        created = false
        dirName = "test_dir_watch_creation"
        duration = 0
        FileWatchCreation(
            duration,
            dirName) {created = true}
        assert(!created)
        `rm -rf #{dirName}`
        `mkdir #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't create dir")
        assert(created)
        `rm -rf #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't remove dir")
    end


    def test_file_watch_creation_no_timing
        created = false
        fileName = "test_file_watch_creation_file1.txt"
        duration = 0
        FileWatchCreation(
            duration,
            fileName) {created = true}
        assert(!created)
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        assert(created)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_creation_no_timing_2
        fileName = "test_file_watch_creation_file11.txt"
        duration = 1

        assert_raise FileNotFound do
            FileWatchCreation(
                duration,
                fileName) {`echo "addition" > #{fileName}`}
            `rm -f #{fileName}`
            `touch #{fileName}`
            assert_equal($?.exitstatus, 0, "couldn't create file")
            `rm -f #{fileName}`
            assert_equal($?.exitstatus, 0, "couldn't remove file")
            sleep(1.5)
            # throw exception
        end
    end

    def test_file_watch_creation_no_timing_3
        fileName1 = "test_file_watch_creation_file111.txt"
        fileName2 = "test_file_watch_creation_file112.txt"
        files = fileName1+","+fileName2
        duration = 1
        total = 0
        FileWatchCreation(
            duration,
            files){total = total + fileName1.hash}

        `rm -f #{fileName1} #{fileName2}`
        `touch #{fileName1} #{fileName2}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        sleep(2)
        assert_equal(fileName1.hash + fileName2.hash, total)
        `rm -f #{fileName1} #{fileName2}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_all
        fileName1 = "test_file1.txt"
        duration = 1
        created = false
        altered = false
        destroyed = false

        FileWatchCreation(
            duration,
            fileName1
        ){created = true}

        FileWatchAlter(
            duration,
            fileName1
        ){altered = true}

        FileWatchDestroy(
            duration,
            fileName1
        ){destroyed = true}
        assert( ! created)
        assert( ! altered)
        assert( ! destroyed)

        `rm -rf #{fileName1}`
        `touch #{fileName1}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        sleep(1.1)
        assert(created)

        `echo "edit" > #{fileName1}`
        assert_equal($?.exitstatus, 0, "couldn't edit file")
        sleep(1.1)
        assert(altered)

        `rm -rf #{fileName1}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
        sleep(1.1)
        assert(destroyed)

    end

    def test_file_watch_all2
        fileName1 = "test_file2.txt"
        `rm -rf #{fileName1}`

        duration = 1
        created = false
        altered = false
        destroyed = false

        FileWatchCreation(
            duration,
            fileName1
        ){created = true}

        FileWatchAlter(
            duration,
            fileName1
        ){altered = true}

        FileWatchDestroy(
            duration,
            fileName1
        ){destroyed = true}
        assert( ! created)
        assert( ! altered)
        assert( ! destroyed)

        `touch #{fileName1}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        sleep(1.1)
        assert(created)

        `echo "edit" > #{fileName1}`
        assert_equal($?.exitstatus, 0, "couldn't edit file")
        sleep(1.1)
        assert(altered)

        `rm -rf #{fileName1}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
        sleep(1.1)
        assert(destroyed)

    end



    def test_file_watch_creation_no_timing_4
        fileName1 = "test_file_watch_creation_file113.txt"
        fileName2 = "test_file_watch_creation_file114.txt"
        files = [fileName1,fileName2]
        duration = 1
        total = 0
        FileWatchCreation(
            duration,
            files){total = total + fileName1.hash}

        `rm -f #{fileName1} #{fileName2}`
        `touch #{fileName1} #{fileName2}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        sleep(2)
        assert_equal(fileName1.hash + fileName2.hash, total)
        `rm -f #{fileName1} #{fileName2}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_altered_no_timing
        altered = false
        fileName = "test_file_watch_alter_file2.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        duration = 0
        FileWatchAlter(
            duration,
            fileName) {altered = true}
        assert(!altered)
        assert_equal($?.exitstatus, 0, "couldn't create file")
        `echo "some crazy edit" >> #{fileName}`
        assert(altered)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_destroyed_no_timing_file_created
        destroyed = false
        fileName = "test_file_watch_destroy_file3.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        duration = 0
        FileWatchAlter(
            duration,
            fileName) {destroyed = true}
        assert(!destroyed)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
        assert(destroyed)
    end

    def test_file_watch_destroyed_no_timing_file_not_created
        destroyed = false
        fileName = "test_file_watch_destroy_file4.txt"
        `rm -f #{fileName}` # just in case
        duration = 0
        assert(!destroyed)
        FileWatchAlter(
            duration,
            fileName) {destroyed = true}
        assert(!destroyed)
    end

    def test_file_watch_destroyed_with_timing
        destroyed = false
        fileName = "test_file_watch_destroy_file5.txt"
        duration = 4
        FileWatchAlter(
            duration,
            fileName) {destroyed = true}
        assert(!destroyed)
        before_destruction = Time.now
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")

        while (Time.now - before_destruction) < duration do
            if destroyed
                assert(false, "Action activated before time duration")
            end
        end
        after_destruction = Time.now
        assert(destroyed)
        assert_in_delta(duration, after_destruction, 0.01)

    end

    def test_file_watch_creation_with_timing
        created = false
        fileName = "test_file_watch_creation_file6.txt"
        duration = 2
        FileWatchCreation(
            duration,
            fileName) {created = true}
        assert(!created)
        before_creation = Time.now
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        while (Time.now - before_creation) < duration do
            if created
                assert(false, "Action activated before time duration")
            end
        end
        after_creation = Time.now
        assert(created)
        assert_in_delta(duration, after_creation, 0.01)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_creation_with_timing_2
        created = false
        fileName = "test_file_watch_creation_file61.txt"
        duration = 2
        FileWatchCreation(
            duration,
            fileName) {created = true}
        assert(!created)
        before_creation = Time.now
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")

        while (Time.now - before_creation) < duration do
            if created
                assert(false, "Action activated before time duration")
            end
        end
        after_creation = Time.now
        assert(created)
        assert_in_delta(duration, after_creation, 0.01)
    end

    def test_file_watch_altered_with_timing
        altered = false
        fileName = "test_file_watch_alter_file7.txt"
        duration = 4
        FileWatchAlter(
            duration,
            fileName) {altered = true}
        assert(!altered)
        before_alteration = Time.now
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        `echo "some crazy edit" >> #{fileName}`

        while (Time.now - before_alteration) < duration do
            if altered
                assert(false, "Action activated before time duration")
            end
        end
        after_alteration = Time.now
        assert(altered)
        assert_in_delta(duration, after_alteration, 0.01)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_altered_with_timing2
        altered = false
        fileName = "test_file_watch_alter_file8.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        duration = 3
        FileWatchAlter(
            duration,
            fileName) {altered = true}
        assert(!altered)
        before_alteration = Time.now
        `echo "some crazy edit" >> #{fileName}`
        while (Time.now - before_alteration) < duration do
            if altered
                assert(false, "Action activated before time duration")
            end
        end
        after_alteration = Time.now
        assert(altered)
        assert_in_delta(duration, after_alteration, 0.01)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_altered_with_timing3
        altered = false
        fileName = "test_file_watch_alter_file9.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        `echo "" > #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        duration = 3
        FileWatchAlter(
            duration,
            fileName) {altered = true}
        assert(!altered)
        before_alteration = Time.now
        `echo "some crazy edit" >> #{fileName}`

        sleep(1)
        `echo "" > #{fileName}` # revert alteration

        while (Time.now - before_alteration) < duration do
            if altered
                assert(false, "Action activated before time duration")
            end
        end
        after_alteration = Time.now
        assert(altered)
        assert_in_delta(duration, after_alteration, 0.01)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end


end

module Kernel

    def capture_stdout
        out = StringIO.new
        $stdout = out
        yield
        return out
    ensure
        $stdout = STDOUT
    end

end
