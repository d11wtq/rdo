require "spec_helper"

describe RDO::Driver do
  describe "#initialize" do
    it "does not call #open" do
      RDO::DriverWithEverything.new.should_not be_open
    end
  end

  describe "#prepare" do
    let(:driver) { RDO::DriverWithoutStatements.new }

    it "returns a StatementExecutor" do
      driver.prepare("SELECT * FROM bob WHERE ?").
        should be_a_kind_of(RDO::EmulatedStatementExecutor)
    end

    it "has the correct command" do
      driver.prepare("SELECT * FROM bob WHERE ?").command.
        should == "SELECT * FROM bob WHERE ?"
    end

    it "calls #execute on the driver" do
      driver.should_receive(:execute).
        with("SELECT * FROM bob WHERE ?", true).
        and_return(RDO::Result.new([]))
      stmt = driver.prepare("SELECT * FROM bob WHERE ?")
      stmt.execute(true).should be_a_kind_of(RDO::Result)
    end
  end

  describe "#interpolate" do
    let(:driver) { RDO::DriverWithBackwardsQuote.new }

    it "interpolates nil as literal NULL" do
      driver.send(:interpolate, "SELECT ?", [nil]).should == "SELECT NULL"
    end

    it "interpolates a Fixnum as a literal integer" do
      driver.send(:interpolate, "SELECT ? * 4", [123456789]).should == "SELECT 123456789 * 4"
    end

    it "interpolates a Float as a literal float" do
      driver.send(:interpolate, "SELECT ? * 4", [12.34]).should == "SELECT 12.34 * 4"
    end

    it "interpolates a String as a quoted String" do
      driver.send(:interpolate, "SELECT ?", ["string"]).should == "SELECT 'gnirts'"
    end

    it "interpolates an Object as a quoted String" do
      driver.send(:interpolate, "SELECT ?", [Date.new(2012, 9, 22)]).should == "SELECT '22-90-2102'"
    end

    it "interpolates multiple params" do
      driver.send(
        :interpolate,
        "SELECT ?, ?, ?",
        ["test", 42, nil]
      ).should == "SELECT 'tset', 42, NULL"
    end

    context "with not enough params" do
      it "raises an ArgumentError" do
        expect {
          driver.send(
            :interpolate,
            "SELECT ?, ?, ?",
            ["test", 42]
          )
        }.to raise_error(ArgumentError)
      end
    end

    context "with too many params" do
      it "raises an ArgumentError" do
        expect {
          driver.send(
            :interpolate,
            "SELECT ?, ?",
            ["test", 42, nil]
          )
        }.to raise_error(ArgumentError)
      end
    end

    context "with marks placed inside single quotes" do
      it "ignores the quoted marks" do
        driver.send(
          :interpolate,
          "SELECT 'quoted?', ?, ?",
          ["test", 42]
        ).should == "SELECT 'quoted?', 'tset', 42"
      end
    end

    context "with marks placed inside double quotes" do
      it "ignores the quoted marks" do
        driver.send(
          :interpolate,
          "SELECT \"quoted?\", ?, ?",
          ["test", 42]
        ).should == "SELECT \"quoted?\", 'tset', 42"
      end
    end

    context "with marks placed inside multiline comments" do
      it "ignores the comments marks" do
        driver.send(
          :interpolate,
          "SELECT /* commented? */ ?, ?",
          ["test", 42]
        ).should == "SELECT /* commented? */ 'tset', 42"
      end
    end

    context "with marks placed inside line comments" do
      it "ignores the comments marks" do
        driver.send(
          :interpolate,
          "SELECT\n  -- commented?\n  ?, ?",
          ["test", 42]
        ).should == "SELECT\n  -- commented?\n  'tset', 42"
      end
    end
  end
end
