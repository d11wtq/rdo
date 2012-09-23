require "spec_helper"

describe RDO::Driver do
  describe "#initialize" do
    it "does not call #open" do
      RDO::DriverWithEverything.new.should_not be_open
    end
  end

  describe "#prepare" do
    let(:driver) { RDO::DriverWithoutStatements.new }

    it "returns a Statement" do
      driver.prepare("SELECT * FROM bob WHERE ?").should be_a_kind_of(RDO::Statement)
    end

    it "has the correct command" do
      driver.prepare("SELECT * FROM bob WHERE ?").command.should == "SELECT * FROM bob WHERE ?"
    end

    it "calls #execute on the driver" do
      driver.should_receive(:execute).
        with("SELECT * FROM bob WHERE ?", true).
        and_return(RDO::Result.new([]))
      stmt = driver.prepare("SELECT * FROM bob WHERE ?")
      stmt.execute(true).should be_a_kind_of(RDO::Result)
    end
  end
end
