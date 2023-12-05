require 'spec_helper'
require File.join(".","lib","option_handler.rb")

describe OptionHandler do
    subject { described_class.new }

    describe "#assign_action" do
        let(:action) { :create }

        context "when no action option already exists" do
            let(:options) { {} }

            it "assigns the action to the option hash" do
                expect {
                    subject.send(:assign_action, options, action)
                }.to change { options[:action] }.from(nil).to(action)
            end
        end

        context "when an action option already exists" do
            let(:options) { { action: action} }
            let(:err_output) do
                "You may only include one of the following flags: --create, --modify, --delete, --generate-network-traffic\n"
            end

            it "doesn't update the option, relays an error message, and exits early" do
                expect {
                    subject.send(:assign_action, options, action)
                }.to output(err_output).to_stdout.and raise_error(SystemExit) { |err| expect(err.status).to eq(1) }
            end
        end
    end

    describe "#assign_filepath" do
        let(:filepath) { File.join("some", "file", "path") }

        context "when no filepath option already exists" do
            let(:options) { {} }

            it "assigns the action to the option hash" do
                expect {
                    subject.send(:assign_filepath, options, filepath)
                }.to change { options[:filepath] }.from(nil).to(filepath)
            end
        end

        context "when an action option already exists" do
            let(:options) { { filepath: filepath} }
            let(:err_output) { "You may only include one --filepath flag\n" }

            it "doesn't update the option, relays an error message, and exits early" do
                expect {
                    subject.send(:assign_filepath, options, filepath)
                }.to output(err_output).to_stdout.and raise_error(SystemExit) { |err| expect(err.status).to eq(1) }
            end
        end
    end
end
