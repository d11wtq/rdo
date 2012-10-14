require "spec_helper"
require "logger"

describe RDO::Connection do
  after(:each) { RDO::Connection.drivers.clear }

  describe ".register_driver" do
    before(:each) do
      RDO::Connection.register_driver(:bob, RDO::Driver)
    end

    it "registers a driver name for a driver class" do
      RDO::Connection.drivers["bob"].should == RDO::Driver
    end
  end

  describe "#initialize" do
    let(:driver)       { double(:driver, open: true) }
    let(:driver_class) { double(new: driver) }

    before(:each) { RDO::Connection.register_driver(:test, driver_class) }

    context "with a connection uri string" do
      context "for a registered driver" do
        it "instantiates the driver" do
          driver_class.should_receive(:new).and_return(driver)
          RDO::Connection.new("test://whatever")
        end

        it "converts the uri to an options hash" do
          driver_class.should_receive(:new).
            with(hash_including(driver: "test")).
            and_return(driver)

          RDO::Connection.new("test://whatever")
        end

        it "parses the host name" do
          driver_class.should_receive(:new).
            with(hash_including(host: "whatever")).
            and_return(driver)

          RDO::Connection.new("test://whatever:3456")
        end

        it "parses the username" do
          driver_class.should_receive(:new).
            with(hash_including(user: "bob")).
            and_return(driver)

          RDO::Connection.new("test://bob:@whatever:3456")
        end

        it "parses the password" do
          driver_class.should_receive(:new).
            with(hash_including(password: "secret")).
            and_return(driver)

          RDO::Connection.new("test://user:secret@whatever:3456")
        end

        it "parses the port number" do
          driver_class.should_receive(:new).
            with(hash_including(port: 3456)).
            and_return(driver)

          RDO::Connection.new("test://whatever:3456")
        end

        it "parses the path" do
          driver_class.should_receive(:new).
            with(hash_including(path: "/some/path.db")).
            and_return(driver)

          RDO::Connection.new("test://whatever/some/path.db")
        end

        it "parses the database name" do
          driver_class.should_receive(:new).
            with(hash_including(database: "my_db")).
            and_return(driver)

          RDO::Connection.new("test://whatever/my_db")
        end

        it "parses the encoding" do
          driver_class.should_receive(:new).
            with(hash_including(encoding: "utf-8")).
            and_return(driver)

          RDO::Connection.new("test://whatever/my_db?encoding=utf-8")
        end

        it "parses driver-specific options" do
          driver_class.should_receive(:new).
            with(hash_including(special_mode: "true")).
            and_return(driver)

          RDO::Connection.new("test://whatever/my_db?encoding=utf-8&special_mode=true")
        end

        context "with only a path" do
          it "parses the path" do
            driver_class.should_receive(:new).
              with(hash_including(path: "/some/path.db")).
              and_return(driver)

            RDO::Connection.new("test:/some/path.db")
          end
        end

        it "invokes #open on the driver" do
          driver.should_receive(:open).and_return(true)
          RDO::Connection.new("test://host/db")
        end
      end

      context "for an unknown driver" do
        it "raises an RDO::Exception" do
          expect {
            RDO::Connection.new("wat://ever")
          }.to raise_error(RDO::Exception)
        end
      end
    end

    context "with an options hash" do
      context "for a registered driver" do
        it "instantiates the driver" do
          driver_class.should_receive(:new).and_return(driver)
          RDO::Connection.new(driver: :test, host: "whatever")
        end

        it "passes the options to the driver" do
          driver_class.should_receive(:new).
            with(hash_including(host: "whatever")).
            and_return(driver)
          RDO::Connection.new(driver: :test, host: "whatever")
        end

        it "invokes #open on the driver" do
          driver.should_receive(:open).and_return(true)
          RDO::Connection.new(driver: :test, host: "whatever")
        end
      end

      context "for an unknown driver" do
        it "raises an RDO::Exception" do
          expect {
            RDO::Connection.new(driver: :wat, host: "test")
          }.to raise_error(RDO::Exception)
        end
      end
    end
  end

  describe "driver methods" do
    let(:connection)   { RDO::Connection.new("test://host") }
    let(:driver)       { double(:driver, open: true) }
    let(:driver_class) { double(new: driver) }

    before(:each) do
      RDO::Connection.register_driver(:test, driver_class)
      connection
    end

    describe "#open" do
      it "delegates to the driver" do
        driver.should_receive(:open).and_return(true)
        connection.open.should == true
      end
    end

    describe "#close" do
      it "delegates to the driver" do
        driver.should_receive(:close).and_return(true)
        connection.close.should == true
      end
    end

    describe "#open?" do
      it "delegates to the driver" do
        driver.should_receive(:open?).and_return(false)
        connection.should_not be_open
      end
    end

    describe "#execute" do
      let(:result) { RDO::Result.new([]) }

      it "delegates to the driver" do
        driver.should_receive(:execute).
          with("SELECT * FROM bob WHERE ?", true).
          and_return(result)
        connection.execute("SELECT * FROM bob WHERE ?", true).should == result
      end

      context "with debug logging" do
        before(:each) do
          connection.logger.level = Logger::DEBUG
          driver.stub(:execute).and_return(result)
        end

        it "logs the statement" do
          connection.logger.should_receive(:debug).
            with(/SELECT \* FROM bob WHERE \?.*?true/)
          connection.execute("SELECT * FROM bob WHERE ?", true)
        end
      end

      context "without debug logging" do
        before(:each) do
          connection.logger.level = Logger::INFO
          driver.stub(:execute).and_return(result)
        end

        it "does not log the statement" do
          connection.logger.should_not_receive(:debug)
          connection.execute("SELECT * FROM bob WHERE ?", true)
        end
      end

      context "when an RDO::Exception occurs" do
        before(:each) do
          driver.stub(:execute).and_raise(RDO::Exception.new("some error"))
        end

        context "with fatal logging" do
          before(:each) do
            connection.logger.level = Logger::FATAL
          end

          it "logs the error" do
            begin
              connection.logger.should_receive(:fatal).
                with(/some error/)
              connection.execute("SELECT * FROM bob WHERE ?", true)
              fail("RDO::Exception should be raised")
            rescue
              # expected
            end
          end
        end

        context "without debug logging" do
          before(:each) do
            connection.logger.level = Logger::UNKNOWN
          end

          it "does not log the error" do
            begin
              connection.logger.should_not_receive(:fatal)
              connection.execute("SELECT * FROM bob WHERE ?", true)
              fail("RDO::Exception should be raised")
            rescue
              # expected
            end
          end
        end
      end
    end

    describe "#prepare" do
      let(:command)  { "SELECT * FROM bob WHERE ?" }
      let(:executor) { stub(command: command) }

      it "delegates to the driver" do
        driver.should_receive(:prepare).with(command).and_return(executor)
        connection.prepare(command).command.should == command
      end

      it "returns a RDO::Statement" do
        driver.stub(:prepare).and_return(executor)
        connection.prepare(command).should be_a_kind_of(RDO::Statement)
      end
    end

    describe "#quote" do
      let(:quoted) { "Weird ['] quotes" }

      it "delegates to the driver" do
        driver.should_receive(:quote).
          with("Weird ' quotes").
          and_return(quoted)
        connection.quote("Weird ' quotes").should == quoted
      end
    end
  end

  describe "#debug" do
    let(:connection)   { RDO::Connection.new("test://host") }
    let(:driver)       { double(:driver, open: true) }
    let(:driver_class) { double(new: driver) }

    before(:each) do
      RDO::Connection.register_driver(:test, driver_class)
      connection
    end

    it "sets the log level to debug" do
      connection.logger.level = Logger::FATAL
      level = nil
      connection.debug { level = connection.logger.level }
      level.should == Logger::DEBUG
    end

    it "restores the log level" do
      connection.logger.level = Logger::FATAL
      connection.debug { }
      connection.logger.level.should == Logger::FATAL
    end

    context "when the block raise an Exception" do
      it "restores the log level" do
        connection.logger.level = Logger::FATAL
        begin
          connection.debug { raise "test" }
        rescue
        end
        connection.logger.level.should == Logger::FATAL
      end
    end
  end
end
