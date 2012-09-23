require "spec_helper"

describe RDO::Driver, "emulated prepared statements" do
  let(:driver) { RDO::DriverWithoutStatements.new }

  describe "#command" do
    it "returns the command string" do
      driver.prepare("SELECT * FROM users").command.should == "SELECT * FROM users"
    end
  end

  describe "#execute" do
    let(:result) { stub(:result) }

    it "delegates to the driver" do
      driver.should_receive(:execute).with(
        "SELECT * FROM users WHERE ? AND ?", 1, 2
      ).and_return(result)
      driver.prepare("SELECT * FROM users WHERE ? AND ?").execute(1, 2).should == result
    end
  end
end
