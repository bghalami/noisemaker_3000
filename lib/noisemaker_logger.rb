require 'json'

class NoisemakerLogger
    attr_reader :log_file, :command_line

    def initialize(command_line: "", log_file: File.join(".", "log", "log.json"))
        @log_file = log_file
        @command_line = command_line
    end

    def log_process_start
        log_json = { process_start: shared_log_data }

        write_to_log(log_json)
    end

    def log_file_modification(filepath:, action:)
        log_json = {
          file_activity: {
            filepath:,
            action:
          }.merge(shared_log_data)
        }

        write_to_log(log_json)
    end

    def log_network_traffic(network_log_data)
        log_json = { network_activity: network_log_data.merge(shared_log_data) }

        write_to_log(log_json)
    end

    private

    def write_to_log(json)
        dirname = File.dirname(log_file)
        Dir.mkdir(dirname) unless File.directory?(dirname)

        if File.exist?(log_file)
            json_data = File.read(log_file)
            data = JSON.parse(json_data)

            data = [] unless data.is_a?(Array)

            data << json

            updated_json = JSON.generate(data)
        else
            updated_json = JSON.generate([json])
        end

        File.write(log_file, updated_json)
    end

    def shared_log_data
        {
          start_time: Time.now.strftime("%Y-%m-%d %H:%M:%S.%6N %:z"),
          user: username,
          process_name: $PROGRAM_NAME,
          process_command_line: command_line,
          process_id: current_pid,
        }
    end

    def username
        Gem.win_platform? ? ENV['USERNAME'] : ENV['USER']
    end

    def current_pid
        Process.pid
    end
end
