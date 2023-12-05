require 'spec_helper'
require File.join(".","lib","network_handler.rb")
require File.join(".","lib","noisemaker_logger.rb")

describe NetworkHandler do
    subject { NetworkHandler.new(logger: logger) }

    let(:log_file) { File.join(".","spec","log","log.json") }
    let(:logger) do
        NoisemakerLogger.new(command_line: "--cmd-args", log_file: log_file)
    end

    describe "#call" do
        it "opens a TCPSocket and sends request data" do
            allow(TCPSocket).to receive(:open).and_call_original
            subject.call
            expect(TCPSocket).to have_received(:open)
        end

        it "records network data to send to logger" do
            allow(logger).to receive(:log_network_traffic)
            subject.call
            expect(logger).to have_received(:log_network_traffic).with(subject.network_log_data)
        end
    end
end