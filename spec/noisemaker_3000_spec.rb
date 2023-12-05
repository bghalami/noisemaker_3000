require 'spec_helper'
require './lib/noisemaker_3000.rb'
require './lib/file_handler.rb'
require './lib/network_handler.rb'

describe Noisemaker3000 do
    subject { described_class.new(command_line: command_line) }
    let(:command_line) { "some_cmd" }

    describe "#make_some_noise" do
        it "logs the process start" do
            allow(subject.logger).to receive(:log_process_start)
            subject.make_some_noise
            expect(subject.logger).to have_received(:log_process_start)
        end

        context "action is file modification" do
            let(:options) { { action: action, filepath: filepath } }
            let(:action) { FileHandler::VALID_ACTIONS.sample(1).first }
            let(:filepath) { "valid/filepath.txt" }
            let(:file_handler) { FileHandler.new(options, logger: subject.logger) }

            before do
                allow(subject).to receive(:options).and_return(options)
                allow(FileHandler).to receive(:new).and_return(file_handler)
                allow(file_handler).to receive(:call)
            end

            context "with missing or empty filepath" do
                let(:filepath) { "" }

                it "returns early" do
                    subject.make_some_noise
                    expect(file_handler).to_not have_received(:call)
                end

                it "prints an error message" do
                    expect {
                        subject.make_some_noise
                    }.to output("Must include valid file path to create, modify, or delete file data\n").to_stdout
                end
            end

            context "with a valid filepath" do
                it "calls the file handler" do
                    subject.make_some_noise
                    expect(file_handler).to have_received(:call)
                end
            end
        end

        context "action is network request" do
            let(:options) { {action: :network} }
            let(:network_handler) { NetworkHandler.new(logger: subject.logger) }

            before { allow(subject).to receive(:options).and_return(options) }

            it "calls the network handler" do
                allow(NetworkHandler).to receive(:new).and_return(network_handler)
                allow(network_handler).to receive(:call)

                subject.make_some_noise

                expect(network_handler).to have_received(:call)
            end
        end
    end
end
