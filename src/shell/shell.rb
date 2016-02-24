class Shell

    @@commands = ["cd", "ls", "dir", "pwd", "cwd", "help", "history", 
                  "exit", "quit"]

                  
    def initialize
        @history = []
        @prompt = "#{ENV['USER']}:>> "
        @user_defined_commands = Hash.new
        @pwd = Dir.pwd
    end
    
        
    def get_command
        gets.chomp.split
    end
        
        
    def cd(dir)
        begin
            Dir.chdir(dir)
            @pwd = Dir.pwd
        rescue TypeError
            puts "Please enter a valid directory as the argument to 'cd'."
        rescue Errno::ENOENT
            puts "Invalid directory; '#{dir}' does not exist."
        end
    end   
    

    def ls
        contents = ""
        Dir.entries(".").each {|d| contents += (d + "\n") if File.directory? d}
        Dir.entries(".").each {|f| contents += (f + "\n") if File.file? f}
        contents
    end
    
        
    def run_command(cmd)

        command = cmd[0]
        command_with_args = cmd.join(" ")

        return if command == "" or command == nil
        exit if command == "exit" or command == "quit"

        @history.push(command_with_args) unless command == "history"

        case command
            when "pwd"
                @pwd
            when "cwd"
                @pwd
            when "cd"
                cd cmd[1]
            when "ls"
                ls
            when "dir"
                ls
            when "history"
                puts @history
            when "help"
                puts "List of commands:"
                @@commands.each {|c|}
            else
                `#{command_with_args}`
        end
    end
       
       
    def run
        while 1
            print @prompt
            cmd = get_command
            
            begin
                result = run_command(cmd)
                puts result
            rescue Errno::ENOENT
                puts("Invalid command! Type 'help' for a list of available commands.")
            rescue SystemCallError => e
                e.class.name.start_with?("Errno::") ? puts("#{e.class} #{e.to_s}") : puts("Invalid command! Type 'help' for a list of available commands.")
            end
            
        end
    end

end





 