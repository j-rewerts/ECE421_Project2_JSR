require "test/unit"
require "stringio"
require_relative "fileWatch/fileWatch.rb"
include FileWatch
class Project2Test < Test::Unit::TestCase

    def time_leeway
        return 0.5
    end


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
        destroyed = false
        pipeName = "test_pipe_watch_destruction"
        `rm -rf #{pipeName}`
        `mkfifo #{pipeName}`
        assert_equal($?.exitstatus, 0, "couldn't create pipe")
        duration = 0
        FileWatchDestroy(
            pipeName) {destroyed = true}
        assert(!destroyed)
        before_destruction = Time.now
        `rm -rf #{pipeName}`
        assert_equal($?.exitstatus, 0, "couldn't remove pipe")
        while ( ! destroyed)
        end
        after_destruction = Time.now
        assert(destroyed)
        assert_in_delta(duration, after_destruction - before_destruction, time_leeway, "Action not activated in the appointed time.")
    end

    def test_dir_watch_destroy_no_timing
        destroyed = false
        dirName = "test_dir_watch_destruction"
        `rm -rf #{dirName}`
        `mkdir #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't create dir")
        duration = 0
        FileWatchDestroy(
            dirName) {destroyed = true}
        assert(!destroyed)
        before_destruction = Time.now
        `rm -rf #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't remove dir")
        while ( ! destroyed)
        end
        after_destruction = Time.now
        assert(destroyed)
        assert_in_delta(duration, after_destruction - before_destruction, time_leeway, "Action not activated in the appointed time.")

        `rm -rf #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't remove pipe")
        while ( ! destroyed)
        end
        after_destruction = Time.now
        assert(destroyed)
        assert_in_delta(duration, after_destruction - before_destruction, time_leeway, "Action not activated in the appointed time.")

    end

    def test_dir_watch_all2
        dirName = "test_dir2"
        `rm -rf #{dirName}`
        duration = 0
        created = false
        altered = false
        destroyed = false

        FileWatchCreation(
            dirName
        ){created = true}
        assert( ! created)
        before_creation = Time.now
        `mkdir #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't create dir")
        while (! created)
        end
        after_creation = Time.now
        assert_in_delta(duration, after_creation - before_creation, time_leeway  , "Action not activated in the appointed time.")

        FileWatchAlter(
            dirName
        ){altered = true}

        FileWatchDestroy(
            dirName
        ){destroyed = true}
        assert( ! altered)
        assert( ! destroyed)

        before_alteration = Time.now
        `touch #{dirName}/someFileInTestFolder.txt`

        while (! altered)
        end
        after_alteration = Time.now
        assert_in_delta(duration, after_alteration - before_alteration, time_leeway  , "Action not activated in the appointed time.")


        before_destruction = Time.now
        `rm -rf #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't remove pipe")
        while ( ! destroyed)
        end
        after_destruction = Time.now
        assert(destroyed)
        assert_in_delta(duration, after_destruction - before_destruction, time_leeway, "Action not activated in the appointed time.")

    end

    def test_file_watch_bad_duration
        duration = -1
        fileName = "asd"
        assert_raise TypeError do
            FileWatchCreation(
                duration,
                fileName) { puts "test"}
        end
        duration = -9999999
        assert_raise TypeError do
            FileWatchAlter(
                duration,
                fileName) {puts "test"}
        end
        duration = -999999999999
        assert_raise TypeError do
            FileWatchDestroy(
                duration,
                fileName) {puts "test"}
        end
    end

    def test_file_watch_no_action
        assert_raise ArgumentError do
            FileWatchCreation(
                1,
                "as")
        end
        assert_raise ArgumentError do
            FileWatchAlter(
                1,
                "as")
        end
        assert_raise ArgumentError do
            FileWatchDestroy(
                1,
                "as")
        end

    end

    def test_file_watch_bad_fileName
        duration = 1
        fileName = 23
        assert_raise TypeError do
            FileWatchCreation(
                duration,
                fileName) {destroyed = true}
        end
        fileName = 21023.123941
        assert_raise TypeError do
            FileWatchAlter(
                duration,
                fileName) {destroyed = true}
        end
        fileName = Hash.new
        assert_raise TypeError do
            FileWatchDestroy(
                duration,
                fileName) {destroyed = true}
        end
    end


    def test_file_watch_bad_fileName2
        duration = 1
        fileName = [23]
        assert_raise TypeError do
            FileWatchCreation(
                duration,
                fileName) {destroyed = true}
        end
        fileName = [[Hash.new],"file.txt"]
        assert_raise TypeError do
            FileWatchAlter(
                duration,
                fileName) {destroyed = true}
        end
        fileName = [["asd"]]
        assert_raise TypeError do
            FileWatchDestroy(
                duration,
                fileName) {destroyed = true}
        end
    end

    def test_file_watch_bad_fileName3
        duration = 1
        fileName = []
        assert_raise ArgumentError do
            FileWatchCreation(
                duration,
                fileName) {destroyed = true}
        end
        assert_raise ArgumentError do
            FileWatchAlter(
                duration,
                fileName) {destroyed = true}
        end
        assert_raise ArgumentError do
            FileWatchDestroy(
                duration,
                fileName) {destroyed = true}
        end
    end


    def test_file_in_dir_delete
        destroyed = false
        dirName = "test_dir31"
        fileName = "#{dirName}/test_file_watch_destroy_file3.txt"
        `rm -rf #{fileName} #{dirName}`
        `mkdir #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't create dir")
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        duration = 0
        FileWatchAlter(
            fileName) {destroyed = true}
        assert(!destroyed)
        before_destruction = Time.now
        `rm -rf #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
        while ( ! destroyed)
        end
        after_destruction = Time.now
        assert(destroyed)
        assert_in_delta(duration, after_destruction - before_destruction, time_leeway, "Action not activated in the appointed time.")
        `rm -rf #{dirName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_metadata_change2
        altered = false
        fileName = "test_file_watch_alter_file212.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        duration = 0
        FileWatchAlter(
            fileName) {altered = true}
        assert(!altered)
        before_alteration = Time.now
        `mv  #{fileName} ~/`
        assert_equal($?.exitstatus, 0, "couldn't move file")

        while (! altered)
        end
        after_alteration = Time.now
        assert_in_delta(duration, after_alteration - before_alteration, time_leeway  , "Action not activated in the appointed time.")
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end


    def test_file_watch_metadata_change
        altered = false
        fileName = "test_file_watch_alter_file211.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        duration = 0
        FileWatchAlter(
            fileName) {altered = true}
        assert(!altered)
        before_alteration = Time.now
        `chmod +x  #{fileName}`

        while (! altered)
        end
        after_alteration = Time.now
        assert_in_delta(duration, after_alteration - before_alteration, time_leeway  , "Action not activated in the appointed time.")
        `rm -f #{fileName}`
    end

    def test_file_watch_creation_no_timing_4
        fileName1 = "test_file_watch_creation_file113.txt"
        fileName2 = "test_file_watch_creation_file114.txt"
        `rm -f #{fileName1} #{fileName2}`
        files = [fileName1,fileName2]
        duration = 0
        total = 0
        FileWatchCreation(
            files){total = total + fileName2.hash}
        before_creation = Time.now
        `touch #{fileName1} #{fileName2}`
        assert_equal($?.exitstatus, 0, "couldn't create file")

        while (total != fileName2.hash + fileName2.hash)
        end
        after_creation = Time.now
        assert_in_delta(duration, after_creation - before_creation, time_leeway  , "Action not activated in the appointed time.")
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
            fileName) {altered = true}
        assert(!altered)
        before_alteration = Time.now
        `echo "some crazy edit" >> #{fileName}`

        while (! altered)
        end
        after_alteration = Time.now
        assert_in_delta(duration, after_alteration - before_alteration, time_leeway  , "Action not activated in the appointed time.")
        `rm -f #{fileName}`
    end

    def test_file_watch_destroyed_no_timing_file_created
        destroyed = false
        fileName = "test_file_watch_destroy_file3.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        duration = 0
        FileWatchDestroy(
            fileName) {destroyed = true}
        assert(!destroyed)
        before_destruction = Time.now
        `rm -rf #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
        while ( ! destroyed)
        end
        after_destruction = Time.now
        assert(destroyed)
        assert_in_delta(duration, after_destruction - before_destruction, time_leeway, "Action not activated in the appointed time.")
    end

    def test_file_watch_destroyed_no_timing_file_not_created
        destroyed = false
        fileName = "test_file_watch_destroy_file4.txt"
        `rm -f #{fileName}` # just in case
        duration = 0
        assert(!destroyed)
        assert_raise FileNotFound do
            FileWatchDestroy(
                fileName) {destroyed = true}
        end
    end

    def test_file_watch_destroyed_with_timing
        destroyed = false
        fileName = "test_file_watch_destroy_file5.txt"
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        duration = 1.9343
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
        assert_in_delta(duration, after_destruction - before_destruction, time_leeway  , "Action not activated in the appointed time.")

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
        assert_in_delta(duration, after_creation - before_creation, time_leeway  , "Action not activated in the appointed time.")
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
        assert_in_delta(duration, after_creation - before_creation, time_leeway  , "Action not activated in the appointed time.")

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
        assert_in_delta(duration, after_alteration - before_alteration, time_leeway  , "Action not activated in the appointed time.")
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
        assert_in_delta(duration, after_alteration - before_alteration, time_leeway  , "Action not activated in the appointed time.")
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
        assert_in_delta(duration, after_alteration - before_alteration, time_leeway  , "Action not activated in the appointed time.")
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
