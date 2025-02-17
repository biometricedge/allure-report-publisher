RSpec.describe Publisher::Helpers do
  subject(:helpers) { described_class }

  include_context "with mock helper"

  context "with common helpers" do
    it "colorizes string" do
      expect(Pastel.new.colored?(helpers.colorize("message", :green))).to be_truthy # rubocop:disable RSpec/PredicateMatcher
    end

    it "returns joined path" do
      expect(helpers.path("path", "to", "file")).to eq("path/to/file")
    end
  end

  context "with successful shell command execution" do
    it "executes shell command" do
      aggregate_failures do
        expect(helpers.execute_shell("command")).to eq(cmd_out)
        expect(Open3).to have_received(:capture3).with("command")
      end
    end

    it "passes allure executable check" do
      expect { helpers.validate_allure_cli_present }.not_to raise_error
    end
  end

  context "with unsuccessful shell command execution" do
    let(:cmd_status) { false }

    it "raises error with command output" do
      expect { helpers.execute_shell("command") }.to raise_error("Out:\n#{cmd_out}\n\nErr:\n#{cmd_err}")
    end

    it "raises error that allure is missing" do
      error = Pastel.new(enabled: true).decorate(
        "Allure cli is missing! See https://docs.qameta.io/allure/#_installing_a_commandline on how to install it!",
        :red
      )
      expect do
        expect { helpers.validate_allure_cli_present }.to raise_error(SystemExit)
      end.to output("#{error}\n").to_stderr
    end
  end
end
