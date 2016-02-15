require "test/unit"
require "stringio"
require_relative "fileWatch/fileWatch.rb"
include FileWatch
class Project2Test < Test::Unit::TestCase

    @success = 0

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

    def test_file_watch_creation_no_timing
        created = false
        fileName = "test_file_watch_creation_file1.txt"
        duration = 0
        FileWatchCreation(
            duration,
            fileName) {|f| created = true if f == fileName}
        assert(!created)
        `rm -f #{fileName}`
        `touch #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't create file")
        assert(created)
        `rm -f #{fileName}`
        assert_equal($?.exitstatus, 0, "couldn't remove file")
    end

    def test_file_watch_altered_no_timing
        altered = false
        fileName = "test_file_watch_alter_file2.txt"
        duration = 0
        FileWatchAlter(
            duration,
            fileName) {|f| altered = true if f == fileName}
        assert(!altered)
        `rm -f #{fileName}`
        `touch #{fileName}`
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
            fileName) {|f| destroyed = true if f == fileName}
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
            fileName) {|f| destroyed = true if f == fileName}
        assert(!destroyed)
    end

    def test_file_watch_destroyed_with_timing
        destroyed = false
        fileName = "test_file_watch_destroy_file5.txt"
        duration = 4
        FileWatchAlter(
            duration,
            fileName) {|f| destroyed = true if f == fileName}
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
            fileName) {|f| created = true if f == fileName}
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

    def test_file_watch_altered_with_timing
        altered = false
        fileName = "test_file_watch_alter_file7.txt"
        duration = 4
        FileWatchAlter(
            duration,
            fileName) {|f| altered = true if f == fileName}
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
            fileName) {|f| altered = true if f == fileName}
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
