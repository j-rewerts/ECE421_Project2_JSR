require "test/unit"
require "stringio"

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