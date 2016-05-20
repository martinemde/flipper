require 'helper'
require 'flipper/adapters/operation_logger'
require 'flipper/adapters/memory'
require 'flipper/spec/shared_adapter_specs'

RSpec.describe Flipper::Adapters::OperationLogger do
  let(:operations) { [] }
  let(:adapter)    { Flipper::Adapters::Memory.new }
  let(:flipper)    { Flipper.new(adapter) }

  subject { described_class.new(adapter, operations) }

  it_should_behave_like 'a flipper adapter'

  describe "#get" do
    before do
      adapter.set("foo", "bar")
      @result = subject.get("foo")
    end

    it "logs operation" do
      expect(subject.count(:get)).to be(1)
    end

    it "returns result" do
      expect(@result).to eq(adapter.get("foo"))
    end
  end

  describe "#mget" do
    before do
      adapter.set("foo", "foo_value")
      adapter.set("bar", "bar_value")
      @result = subject.mget(["foo", "bar"])
    end

    it "logs operation" do
      expect(subject.count(:mget)).to be(1)
    end

    it "returns result" do
      expect(@result).to eq(adapter.mget(["foo", "bar"]))
    end
  end

  describe "#set" do
    before do
      @result = subject.set("foo", "bar")
    end

    it "logs operation" do
      expect(subject.count(:set)).to be(1)
    end

    it "returns result" do
      expect(@result).to eq(adapter.set("foo", "bar"))
    end
  end

  describe "#mset" do
    before do
      @result = subject.mset("foo" => "bar")
    end

    it "logs operation" do
      expect(subject.count(:mset)).to be(1)
    end

    it "returns result" do
      expect(@result).to eq(adapter.mset("foo" => "bar"))
    end
  end

  describe "#del" do
    before do
      @result = subject.del("foo")
    end

    it "logs operation" do
      expect(subject.count(:del)).to be(1)
    end

    it "returns result" do
      expect(@result).to eq(adapter.del("foo"))
    end
  end

  describe "#mdel" do
    before do
      adapter.set("foo", "bar")
      @result = subject.mdel(["foo"])
    end

    it "logs operation" do
      expect(subject.count(:mdel)).to be(1)
    end

    it "returns result" do
      expect(@result).to eq(adapter.mdel(["foo"]))
    end
  end
end
