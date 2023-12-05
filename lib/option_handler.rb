require 'optparse'

class OptionHandler
    attr_accessor :options

    def initialize
        @options = {}
        handle_options
    end

    def handle_options
        begin
            OptionParser.new do |opts|
                opts.banner = "Usage: make_some_noise.rb [options]"

                opts.on("--filepath PATH", String, "Filepath to new file") { |fp| assign_filepath(options, fp.strip) }
                opts.on("-c", "--create", "Create a new file") { |_| assign_action(options, :create) }
                opts.on("-m", "--modify", "Modify an existing .txt file") { |_| assign_action(options, :modify) }
                opts.on("-D", "--delete", "Delete an existing file") { |_| assign_action(options, :delete) }
                opts.on("-g", "--generate-network-traffic", "Generate network traffic") { |_| assign_action(options, :network) }
                opts.on("-h", "--help", "Display how to interact with app") { |_| puts opts; exit 1 }
            end.parse!
        rescue OptionParser::InvalidOption => error
            puts "#{error.message}, run 'make_some_noise.rb --help' for a list of valid flags"
            exit 1
        end
    end

    private

    def assign_action(options, action)
        if options[:action]
            puts "You may only include one of the following flags: --create, --modify, --delete, --generate-network-traffic"
            exit 1
        else
            options[:action] = action
        end
    end

    def assign_filepath(options, filepath)
        if options[:filepath]
            puts "You may only include one --filepath flag"
            exit 1
        else
            options[:filepath] = filepath
        end
    end
end
