require "spec_helper"

describe RDO::Result do
  it "is enumerable" do
    RDO::Result.new([]).should be_a_kind_of(Enumerable)
  end

  describe "#each" do
    let(:result) { RDO::Result.new([{id: 7}, {id: 42}]) }

    it "enumerates all tuples" do
      tuples = []
      result.each{|row| tuples << row}
      tuples.should == [{id: 7}, {id: 42}]
    end
  end

  describe "#info" do
    let(:result) { RDO::Result.new([], foo: "bar", zip: 42) }

    it "returns all info passed to #initialize" do
      result.info.should == {foo: "bar", zip: 42}
    end
  end

  describe "#count" do
    context "when provided in the info" do
      let(:result) { RDO::Result.new([{id: 7}, {id: 42}], count: 50) }

      it "returns the count from the info" do
        result.count.should == 50
      end

      context "with a block given" do
        it "delegates to Enumerable" do
          result.count{|row| row[:id] > 10}.should == 1
        end
      end
    end

    context "when not provided in the info" do
      let(:result) { RDO::Result.new([{id: 7}, {id: 42}]) }

      it "delegates to Enumerable" do
        result.count.should == 2
      end
    end
  end
end
