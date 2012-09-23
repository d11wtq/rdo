require "spec_helper"

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
      end

      context "for an unknown driver" do
        it "raises an RDO::Exception" do
          expect {
            RDO::Connection.new("wat://ever")
          }.to raise_error(RDO::Exception)
        end
      end
    end
  end
end
