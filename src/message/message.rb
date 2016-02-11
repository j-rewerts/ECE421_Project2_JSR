#!/usr/bin/env ruby

require_relative 'timer'

class String
    def is_i?
        /\A[+]?\d+\z/ === self
    end
end

MAX_SIZE = (2**(0.size * 8 -2) -1)
hasDuration = false
hasMessage = false
duration = 0
message = ""

if ARGV.size != 2
    puts "Please use the form: driver duration message, where driver is the executable file."
    abort
end

ARGV.each do |value|

    if !hasDuration
        if !(value.is_i?)
            puts "The first parameter must be an integer between 0 and 999,999,999."
            abort
        end

        if value.length > 9
            puts "The max duration value is 999,999,999."
            abort
        end

        duration = value.to_i
        hasDuration = true
    elsif !hasMessage
        message = value
        hasMessage = true
    else
        puts "Please use the form: driver duration message, where driver is the executable file."
        abort
    end 
end

Timer.new(duration)
print message + "\n"