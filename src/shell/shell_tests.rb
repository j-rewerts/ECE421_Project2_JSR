require "test/unit"
require_relative "shell.rb"

class ShellTest < Test::Unit::TestCase

    def test_pwd
        s = Shell.new
        
        assert_equal(s.run_command(["pwd"]), Dir.pwd)
        
        s.run_command(["cd", "c:\\users"])
        assert_equal(s.run_command(["pwd"]), "c:/users")
        
        s.run_command(["cd", ".."])
        assert_equal(s.run_command(["pwd"]), "c:/")
        
        s.run_command(["cd", ".."])
        assert_equal(s.run_command(["pwd"]), "c:/")
        
        # Test invalid directories: prints an error to console and returns nil.
        assert_equal(s.run_command(["cd", "asd"]), nil)
        assert_equal(s.run_command(["pwd"]), "c:/")
    end
    
    
    def test_cwd
        s = Shell.new
        
        assert_equal(s.run_command(["cwd"]), Dir.pwd)
        
        s.run_command(["cd", "c:\\users"])
        assert_equal(s.run_command(["cwd"]), "c:/users")
        
        s.run_command(["cd", ".."])
        assert_equal(s.run_command(["cwd"]), "c:/")
        
        s.run_command(["cd", ".."])
        assert_equal(s.run_command(["cwd"]), "c:/")
        
        # Test invalid directories: prints an error to console and returns nil.
        assert_equal(s.run_command(["cd", "asd"]), nil)
        assert_equal(s.run_command(["cwd"]), "c:/")
    end

    
    def test_cd
    
        s = Shell.new
    
        s.run_command(["cd", "c:\\users"])
        assert_equal(s.run_command(["pwd"]), "c:/users")
        
        s.run_command(["cd", ".."])
        assert_equal(s.run_command(["pwd"]), "c:/")
        
        s.run_command(["cd", ".."])
        assert_equal(s.run_command(["pwd"]), "c:/")
        
        # Test invalid directories: prints an error to console and returns nil.
        assert_equal(s.run_command(["cd", "asd"]), nil)
    end
    
    
    def test_ls
    
        s = Shell.new
            
        contents = ""
        Dir.entries(".").each {|d| contents += (d + "\n") if File.directory? d}
        Dir.entries(".").each {|f| contents += (f + "\n") if File.file? f}
        
        assert_equal(s.run_command(["ls"]), contents)
        
        s.run_command(["cd", ".."])
        contents = ""
        Dir.entries(".").each {|d| contents += (d + "\n") if File.directory? d}
        Dir.entries(".").each {|f| contents += (f + "\n") if File.file? f}
        
        assert_equal(s.run_command(["ls"]), contents)
    end

    
    def test_dir
    
        s = Shell.new
            
        contents = ""
        Dir.entries(".").each {|d| contents += (d + "\n") if File.directory? d}
        Dir.entries(".").each {|f| contents += (f + "\n") if File.file? f}
        
        assert_equal(s.run_command(["dir"]), contents)
        
        s.run_command(["cd", ".."])
        contents = ""
        Dir.entries(".").each {|d| contents += (d + "\n") if File.directory? d}
        Dir.entries(".").each {|f| contents += (f + "\n") if File.file? f}
        
        assert_equal(s.run_command(["dir"]), contents)
    end

end
