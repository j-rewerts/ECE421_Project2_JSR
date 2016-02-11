#!/usr/bin/env ruby

argString = ""
ARGV.each do |value|
    argString = argString + " " + "\"" + value + "\""
end
puts argString
file = File.expand_path File.dirname(__FILE__) + "/message.rb"

pid = spawn("ruby " + file + argString)
Process.detach pid