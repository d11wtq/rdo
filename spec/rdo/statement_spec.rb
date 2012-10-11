require "spec_helper"
require "logger"

describe RDO::Statement do
  let(:logger)   { Logger.new(RDO::Util::DEV_NULL) }
  let(:executor) { double(:executor) }
  let(:stmt)     { RDO::Statement.new(executor, logger) }

  describe "#command" do
    let(:command) { "SELECT * FROM users" }

    it "delegates to the executor" do
      executor.should_receive(:command).and_return(command)
      stmt.command.should == command
    end
  end

  describe "#execute" do
    let(:executor) { double(command: "SELECT * FROM bob WHERE ?", execute: result) }
    let(:result)   { stub(:result, info: {}, execution_time: 0.0) }

    it "delegates to the executor" do
      executor.should_receive(:execute).with(1, 2).and_return(result)
      stmt.execute(1, 2).should == result
    end

    context "with debug logging" do
      before(:each) do
        logger.level = Logger::DEBUG
        executor.stub(:execute).and_return(result)
      end

      it "logs the statement" do
        logger.should_receive(:debug).with(/SELECT \* FROM bob WHERE \?.*?true/)
        stmt.execute(true)
      end
    end

    context "without debug logging" do
      before(:each) do
        logger.level = Logger::INFO
        executor.stub(:execute).and_return(result)
      end

      it "does not log the statement" do
        logger.should_not_receive(:debug)
        stmt.execute(true)
      end
    end

    context "when an RDO::Exception occurs" do
      before(:each) do
        executor.stub(:execute).and_raise(RDO::Exception.new("some error"))
      end

      context "with fatal logging" do
        before(:each) do
          logger.level = Logger::FATAL
        end

        it "logs the error" do
          begin
            logger.should_receive(:fatal).with(/some error/)
            stmt.execute
            fail("RDO::Exception should be raised")
          rescue
            # expected
          end
        end
      end

      context "without debug logging" do
        before(:each) do
          logger.level = Logger::UNKNOWN
        end

        it "does not log the error" do
          begin
            logger.should_not_receive(:fatal)
            stmt.execute
            fail("RDO::Exception should be raised")
          rescue
            # expected
          end
        end
      end
    end
  end
end
