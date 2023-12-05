class FileHandler
    attr_reader :action, :filepath, :logger

    VALID_ACTIONS = [:create, :modify, :delete].freeze

    def initialize(options, logger:)
        @action = options[:action]
        @filepath = options[:filepath]
        @logger = logger
    end

    def call
        return puts("Invalid file action: #{action}") unless valid_action?

        logger.log_file_modification(filepath:, action:) if action_successful?
    end

    def create
        return puts("File already exists") if File.exist?(filepath)

        dirname = File.dirname(filepath)
        Dir.mkdir(dirname) unless File.directory?(dirname)

        File.new(filepath, "w")
    end

    def modify
        return puts("Invalid filepath") unless File.exist?(filepath)

        File.open(filepath, "a") do |file|
            file.write("contents appended by process_id: #{Process.pid}\n")
        end
    end

    def delete
        return puts("Invalid filepath") unless File.exist?(filepath)

        File.delete(filepath)
    end

    def valid_action?
        VALID_ACTIONS.include?(action)
    end

    private

    def action_successful?
        !(public_send(action).nil?)
    end
end
