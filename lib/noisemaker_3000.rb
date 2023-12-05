require_relative 'option_handler.rb'
require_relative 'file_handler.rb'
require_relative 'noisemaker_logger.rb'
require_relative 'network_handler.rb'

class Noisemaker3000
    attr_reader :logger, :options, :command_line

    def initialize(command_line:)
        @command_line = command_line
        @logger = NoisemakerLogger.new(command_line: command_line)
        @options = OptionHandler.new.options
    end

    def make_some_noise
        logger.log_process_start

        if FileHandler::VALID_ACTIONS.include?(options[:action])
            return unless filepath_present?

            FileHandler.new(options, logger: logger).call
        elsif options[:action] == :network
            NetworkHandler.new(logger: logger).call
        end
    end

    def filepath_present?
        if options[:filepath].nil? || options[:filepath].empty?
            puts "Must include valid file path to create, modify, or delete file data"
            return false
        end

        true
    end
end
