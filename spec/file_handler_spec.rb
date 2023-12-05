require 'spec_helper'
require 'fileutils'
require 'securerandom'
require File.join(".","lib","file_handler.rb")
require File.join(".","lib","noisemaker_logger.rb")

describe FileHandler do
    subject { described_class.new(options, logger: logger) }
    let(:options) { { action: action, filepath: filepath } }
    let(:log_file) { File.join(".","spec","log","log_text.txt") }
    let(:filepath) { File.join(".","spec","tmp","new_text.txt") }
    let(:action) { :create }
    let(:logger) do
        NoisemakerLogger.new(command_line: "--cmd-args", log_file: log_file)
    end

    after do
        FileUtils.remove_dir(File.dirname(filepath)) if File.directory?(File.dirname(filepath))
        FileUtils.remove_dir(File.dirname(log_file)) if File.directory?(File.dirname(log_file))
    end

    describe "constants" do
        describe "::VALID_ACTIONS" do
            let(:expected_actions) { [:create, :modify, :delete] }

            it "should return the correct values" do
                expect(described_class::VALID_ACTIONS).to eq(expected_actions)
            end
        end
    end

    describe "#call" do
        context "with valid :action and :filepath" do
            let(:action) { :create }

            it "runs the given action and logs the results" do
                allow(subject).to receive(:create).and_call_original
                allow(logger).to receive(:log_file_modification)
                subject.call
                expect(subject).to have_received(:create)
                expect(logger).to have_received(:log_file_modification)
            end

            context ":create" do
                it "calls the create method" do
                    allow(subject).to receive(:create).and_call_original
                    subject.call
                    expect(subject).to have_received(:create)
                end
            end

            context ":modify" do
                let(:action) { :modify }
                it "calls the modify method" do
                    allow(subject).to receive(:modify).and_call_original
                    subject.call
                    expect(subject).to have_received(:modify)
                end
            end

            context ":delete" do
                let(:action) { :delete }

                it "calls the delete method" do
                    allow(subject).to receive(:delete).and_call_original
                    subject.call
                    expect(subject).to have_received(:delete)
                end
            end
        end

        context "with invalid :action and valid :filepath" do
            context ":invalid" do
                let(:action) { :invalid }

                it "returns early and does not send any methods" do
                    allow(subject).to receive(:public_send)
                    expect { subject.call }.to output("Invalid file action: invalid\n").to_stdout
                    expect(subject).to_not have_received(:public_send)
                end
            end
        end
    end

    describe "#create" do
        context "when file already exists" do
            let(:action) { :create }

            before do
                dirname = File.dirname(filepath)
                FileUtils.mkdir_p(dirname)
                File.new(filepath, "w")
            end

            it "outputs a message to console and returns early" do
                allow(File).to receive(:new)

                expect { subject.call }.to output("File already exists\n").to_stdout
                expect(File).to_not have_received(:new)
            end
        end

        context "when file doesn't already exist" do
            it "it builds the specified filepath and creates the file" do
                expect { subject.call }.to change { File.exist?(filepath) }.from(false).to(true)
            end
        end
    end

    describe "#modify" do
        let(:action) { :modify }

        context "when file already exists" do

            before do
                dirname = File.dirname(filepath)
                FileUtils.mkdir_p(dirname)
                File.new(filepath, "w")
            end

            it "modifies the contents to the file" do
                File.open(filepath, "r") do |file|
                    expect { subject.call }.to change { file.read }.from("").to("contents appended by process_id: #{logger.send(:current_pid)}\n")
                end
            end
        end

        context "when file doesn't already exist" do
            it "outputs a message to console and returns early" do
                allow(File).to receive(:open)

                expect { subject.call }.to output("Invalid filepath\n").to_stdout
                expect(File).to_not have_received(:open)
            end
        end
    end

    describe "#delete" do
        let(:action) { :delete }

        context "when file already exists" do

            before do
                dirname = File.dirname(filepath)
                FileUtils.mkdir_p(dirname)
                File.new(filepath, "w")
            end

            it "deletes the file" do
                expect { subject.call }.to change { File.exist?(filepath) }.from(true).to(false)
            end
        end

        context "when file doesn't already exist" do
            it "outputs a message to console and returns early" do
                allow(File).to receive(:delete)

                expect { subject.call }.to output("Invalid filepath\n").to_stdout
                expect(File).to_not have_received(:delete)
            end
        end
    end

    describe "#valid_actions?" do
        context "action is valid" do
            let(:action) { described_class::VALID_ACTIONS.sample(1).first }

            it "returns true" do
                expect(subject.valid_action?).to be_truthy
            end
        end

        context "action is invalid" do
            let(:action) { :invalid_action }

            it "returns false" do
                expect(subject.valid_action?).to be_falsey
            end
        end
    end
end
