require "spec_helper"

describe RDO::Statement do
  let(:executor) { double(:executor) }
  let(:stmt)     { RDO::Statement.new(executor) }

  describe "#connection" do
    let(:connection) { stub(:connection) }

    it "delegates to the executor" do
      executor.should_receive(:connection).and_return(connection)
      stmt.connection.should == connection
    end
  end

  describe "#command" do
    let(:command) { "SELECT * FROM users" }

    it "delegates to the executor" do
      executor.should_receive(:command).and_return(command)
      stmt.command.should == command
    end
  end

  describe "#execute" do
    let(:result) { stub(:result) }

    it "delegates to the executor" do
      executor.should_receive(:execute).with(1, 2).and_return(result)
      stmt.execute(1, 2).should == result
    end
  end
end
