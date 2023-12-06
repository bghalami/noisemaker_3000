require_relative 'noisemaker_3000.rb'

command_line = "#{$0} #{ARGV.join( ' ' )}"
Noisemaker3000.new(command_line: command_line).make_some_noise
