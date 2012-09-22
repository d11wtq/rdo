require "spec_helper"

describe RDO::Util do
  describe ".system_time_zone" do
    it "returns the time zone of the local system" do
      require "date"
      RDO::Util.system_time_zone.should == DateTime.now.zone
    end
  end

  describe ".float" do
    context "with Infinity" do
      it "returns Float::INFINITY" do
        RDO::Util.float("Infinity").should == Float::INFINITY
      end
    end

    context "with -Infinity" do
      it "returns -Float::INFINITY" do
        RDO::Util.float("-Infinity").should == -Float::INFINITY
      end
    end

    context "with NaN" do
      it "returns Float::NAN" do
        RDO::Util.float("NaN").should be_nan
      end
    end

    context "with a number" do
      it "returns a Float" do
        RDO::Util.float("1.2").should == 1.2
      end
    end

    context "with an exponent" do
      it "returns a Float" do
        RDO::Util.float("1.1E-2").should == Float("1.1E-2")
      end
    end
  end

  describe "decimal" do
    context "with NaN" do
      it "returns NaN" do
        RDO::Util.decimal("NaN").should be_nan
      end
    end

    context "with a number" do
      it "returns a BigDecimal" do
        require "bigdecimal"
        RDO::Util.decimal("1.2").should == BigDecimal("1.2")
      end
    end

    context "with an exponent" do
      it "returns a BigDecimal" do
        require "bigdecimal"
        RDO::Util.decimal("1E-2").should == BigDecimal("1E-2")
      end
    end
  end

  describe ".date" do
    it "returns a Date" do
      RDO::Util.date("2012-09-22").should == Date.new(2012, 9, 22)
    end

    context "with BC" do
      it "returns a Date" do
        RDO::Util.date("431-09-22 BC").should == Date.new(-430, 9, 22)
      end
    end
  end

  describe ".date_time_with_zone" do
    it "returns a DateTime" do
      require "date"
      RDO::Util.date_time_with_zone("2012-09-22 10:04:32 +06:00").should ==
        DateTime.parse("2012-09-22 10:04:32 +06:00")
    end
  end

  describe ".date_time_without_zone" do
    it "returns a DateTime in the system time zone" do
      require "date"
      RDO::Util.date_time_without_zone("2012-09-22 10:04:32").should ==
        DateTime.parse("2012-09-22 10:04:32 #{DateTime.now.zone}")
    end
  end
end
