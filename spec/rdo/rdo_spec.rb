require "spec_helper"

describe RDO do
  let(:driver_class) { stub(new: driver) }
  let(:driver)       { stub(:driver, open: true, close: true) }

  before(:each) { RDO::Connection.register_driver(:test, driver_class) }

  describe ".connect" do
    it "returns a connection for the given driver" do
      RDO.connect("test://whatever").should be_a_kind_of(RDO::Connection)
    end

    it "opens the connection" do
      driver.should_receive(:open).and_return(true)
      RDO.connect("test://whatever")
    end

    it "is aliased as .open" do
      RDO.open("test://whatever").should be_a_kind_of(RDO::Connection)
    end

    context "when given a block" do
      it "yields the connection" do
        conn = nil
        RDO.open("test://whatever") { |c| conn = c }
        conn.should be_a_kind_of(RDO::Connection)
      end

      it "opens the connection" do
        driver.should_receive(:open).and_return(true)
        RDO.open("test://whatever") { |c| }
      end

      it "closes the connection" do
        driver.should_receive(:close).and_return(true)
        RDO.open("test://whatever") { |c| }
      end

      it "returns the result of the block" do
        RDO.open("test://whatever"){ |c| "test" }.should == "test"
      end

      context "on error in block" do
        it "still closes the connection" do
          driver.should_receive(:close).and_return(true)
          begin
            RDO.open("test://whatever") { |c| raise "Blarg" }
          rescue
          end
        end
      end
    end
  end
end
