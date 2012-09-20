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

    it "returns the result" do
      result.each.should equal(result)
    end
  end

  describe "#info" do
    let(:result) { RDO::Result.new([], foo: "bar", zip: 42) }

    it "returns all info passed to #initialize" do
      result.info.should == {foo: "bar", zip: 42}
    end
  end

  describe "#insert_id" do
    context "when provided in the info" do
      let(:result) { RDO::Result.new([], insert_id: 21) }

      it "returns the ID from the info" do
        result.insert_id.should == 21
      end
    end

    context "when not provided in the info" do
      context "and there are tuples" do
        let(:result) { RDO::Result.new([{id: 6, name: "bob"}]) }

        it "infers from the tuples" do
          result.insert_id.should == 6
        end
      end

      context "and there are no tuples" do
        let(:result) { RDO::Result.new([]) }

        it "returns nil" do
          result.insert_id.should be_nil
        end
      end
    end
  end

  describe "#affected_rows" do
    context "when provided in the info" do
      let(:result) { RDO::Result.new([], affected_rows: 3) }

      it "returns the value from the info" do
        result.affected_rows.should == 3
      end
    end

    context "when not provided in the info" do
      let(:result) { RDO::Result.new([]) }

      it "returns nil" do
        result.insert_id.should be_nil
      end
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
