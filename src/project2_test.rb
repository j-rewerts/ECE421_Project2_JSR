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
        sleep(0.001)
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
        sleep(0.001)
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
        sleep(0.001)
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
        sleep(0.001)
        assert(created)
        `rm -rf #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't remove dir")
    end


    def test_file_watch_creation_no_timing
        created = false
        fileName = "test_file_watch_creation_file1.txt"
        `rm -f #{fileName}`
        duration = 0
        FileWatchCreation(
            duration,
            fileName) {created = true}
        assert(!created)
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        sleep(0.001)
        assert(created)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_creation_no_timing_3
        fileName1 = "test_file_watch_creation_file111.txt"
        fileName2 = "test_file_watch_creation_file112.txt"
        `rm -f #{fileName1} #{fileName2}`
        files = fileName1+","+fileName2
        duration = 0
        total = 0
        FileWatchCreation(
            duration,
            files){total = total + fileName1.hash}

        `touch #{fileName1} #{fileName2}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        sleep(0.001)
        assert_equal(fileName1.hash + fileName1.hash, total)
        `rm -f #{fileName1} #{fileName2}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_all
        fileName1 = "test_file1.txt"
        `rm -rf #{fileName1}`
        duration = 0
        created = false
        altered = false
        destroyed = false

        FileWatchCreation(
            duration,
            fileName1
        ){created = true}
        assert( ! created)
        `touch #{fileName1}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        FileWatchAlter(
            duration,
            fileName1
        ){altered = true}

        FileWatchDestroy(
            duration,
            fileName1
        ){destroyed = true}
        assert( ! altered)
        assert( ! destroyed)

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

        duration = 0
        created = false
        altered = false
        destroyed = false

        FileWatchCreation(
            duration,
            fileName1
        ){created = true}
        assert( ! created)
        `touch #{fileName1}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        FileWatchAlter(
            duration,
            fileName1
        ){altered = true}

        FileWatchDestroy(
            duration,
            fileName1
        ){destroyed = true}
        assert( ! altered)
        assert( ! destroyed)

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
        `rm -f #{fileName1} #{fileName2}`
        files = [fileName1,fileName2]
        duration = 0
        total = 0
        FileWatchCreation(
            duration,
            files){total = total + fileName2.hash}

        `touch #{fileName1} #{fileName2}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        sleep(0.001)
        assert_equal(fileName2.hash + fileName2.hash, total)
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
        sleep(0.001)
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
        sleep(0.001)
        assert(destroyed)
    end

    def test_file_watch_destroyed_no_timing_file_not_created
        destroyed = false
        fileName = "test_file_watch_destroy_file4.txt"
        `rm -f #{fileName}` # just in case
        duration = 0
        assert(!destroyed)
        assert_raise FileNotFound do
            FileWatchDestroy(
                duration,
                fileName) {destroyed = true}
        end
    end

    def test_file_watch_destroyed_with_timing
        destroyed = false
        fileName = "test_file_watch_destroy_file5.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        duration = 4
        FileWatchAlter(
            duration,
            fileName) {destroyed = true}
        assert(!destroyed)
        before_destruction = Time.now
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")

        while (! destroyed)
        end
        after_destruction = Time.now
        assert_in_delta(duration, after_destruction - before_destruction, 0.1  , "Action not activated in the appointed time.")

    end

    def test_file_watch_creation_with_timing
        created = false
        fileName = "test_file_watch_creation_file6.txt"
        `rm -f #{fileName}`
        duration = 2
        FileWatchCreation(
            duration,
            fileName) {created = true}
        assert(!created)
        before_creation = Time.now
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        while (! created)
        end
        after_creation = Time.now
        assert_in_delta(duration, after_creation - before_creation, 0.1  , "Action not activated in the appointed time.")
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_creation_with_timing_2
        created = false
        fileName = "test_file_watch_creation_file61.txt"
        `rm -f #{fileName}`
        duration = 2
        FileWatchCreation(
            duration,
            fileName) {created = true}
        assert(!created)
        before_creation = Time.now
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        while (! created)
        end
        after_creation = Time.now
        assert_in_delta(duration, after_creation - before_creation, 0.1  , "Action not activated in the appointed time.")

        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
        assert(created)
    end

    def test_file_watch_altered_with_timing
        altered = false
        fileName = "test_file_watch_alter_file7.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        duration = 4
        FileWatchAlter(
            duration,
            fileName) {altered = true}
        assert(!altered)
        before_alteration = Time.now
        `echo "some crazy edit" >> #{fileName}`

        while (! altered)
        end
        after_alteration = Time.now
        assert_in_delta(duration, after_alteration - before_alteration, 0.1  , "Action not activated in the appointed time.")
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
        while (! altered)
        end
        after_alteration = Time.now
        assert_in_delta(duration, after_alteration - before_alteration, 0.1  , "Action not activated in the appointed time.")
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

        #`echo "" > #{fileName}` # revert alteration

        while (! altered)
        end
        after_alteration = Time.now
        assert_in_delta(duration, after_alteration - before_alteration, 0.1  , "Action not activated in the appointed time.")
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
