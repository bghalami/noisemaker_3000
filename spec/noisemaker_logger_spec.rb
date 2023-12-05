require 'spec_helper'
require 'securerandom'
require 'json'
require File.join(".","lib","noisemaker_logger.rb")

describe NoisemakerLogger do
    subject { described_class.new(command_line: command_line, log_file: log_file) }
    let(:log_file) { File.join(".","spec","log","log.json") }
    let(:command_line) { "some_cmd" }
    let(:shared_log_data) do
        {
          "start_time" => frozen_time.strftime("%Y-%m-%d %H:%M:%S.%6N %:z"),
          "user" => subject.send(:username),
          "process_name" => $PROGRAM_NAME,
          "process_command_line" => command_line,
          "process_id" => subject.send(:current_pid),
        }
    end
    let(:frozen_time) { Time.now }

    before do
        allow(Time).to receive(:now).and_return(frozen_time)

        unless File.exist?(log_file)
            dirname = File.dirname(log_file)
            FileUtils.mkdir_p(dirname)
            File.new(log_file, "w")

            File.write(log_file, [])
        end
    end

    after do
        FileUtils.remove_dir(File.dirname(log_file)) if File.directory?(File.dirname(log_file))
    end

    describe "#log_process_start" do
        let(:expected_data) { { "process_start" => shared_log_data } }

        context "when file already exists" do
            it "writes the correct data to the log_file" do
                subject.log_process_start
                expect(JSON.parse(File.read(log_file)).last).to eq(expected_data)
            end
        end

        context "when file doesn't already exist" do

            before { FileUtils.remove_dir(File.dirname(log_file)) if File.directory?(File.dirname(log_file)) }

            it "it builds the log filepath and updates log" do
                expect { subject.log_process_start }.to change { File.exist?(log_file) }.from(false).to(true)
                expect(JSON.parse(File.read(log_file)).last).to eq(expected_data)
            end
        end
    end

    describe "log_file_modification" do
        let(:expected_data) do
            {
              "file_activity" => {
                "filepath"=> filepath,
                "action"=> "#{action}",
              }.merge(shared_log_data)
            }
        end
        let(:filepath) { File.join("path", "to", "some", "file.txt") }
        let(:action) { :create }

        it "writes the correct data to the log_file" do
            subject.log_file_modification(filepath: filepath, action: action)

            expect(JSON.parse(File.read(log_file)).last).to eq(expected_data)
        end
    end

    describe "#log_network_traffic" do
        let(:network_log_json) do
            {
              "protocol" => "HTTPS",
              "request_size" => "45 bytes",
              "destination_address" => "1.2.3",
              "destination_port" => "44",
              "source_address" => "1.3.2",
              "source_port" => "80",
            }
        end
        let(:expected_data) { { "network_activity" => network_log_json.merge(shared_log_data) }}

        it "writes the correct data to the log_file" do
            subject.log_network_traffic(network_log_json)

            expect(JSON.parse(File.read(log_file)).last).to eq(expected_data)
        end
    end
end
