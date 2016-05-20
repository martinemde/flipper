require 'helper'
require 'flipper/adapters/read_only'

RSpec.describe Flipper::Adapters::ReadOnly do
  let(:actor_class) { Struct.new(:flipper_id) }

  let(:adapter) { Flipper::Adapters::Memory.new }
  let(:flipper) { Flipper.new(subject) }
  let(:feature) { flipper[:stats] }

  let(:boolean_gate) { feature.gate(:boolean) }
  let(:group_gate)   { feature.gate(:group) }
  let(:actor_gate)   { feature.gate(:actor) }
  let(:actors_gate)  { feature.gate(:percentage_of_actors) }
  let(:time_gate)    { feature.gate(:percentage_of_time) }

  subject { described_class.new(adapter) }

  before do
    Flipper.register(:admins) { |actor|
      actor.respond_to?(:admin?) && actor.admin?
    }

    Flipper.register(:early_access) { |actor|
      actor.respond_to?(:early_access?) && actor.early_access?
    }
  end

  after do
    Flipper.unregister_groups
  end

  it "has name that is a symbol" do
    expect(subject.name).to_not be_nil
    expect(subject.name).to be_instance_of(Symbol)
  end

  it "has included the flipper adapter module" do
    expect(subject.class.ancestors).to include(Flipper::Adapter)
  end

  it "returns nil for missing key" do
    expect(subject.get("foo")).to be(nil)
  end

  it "can get multiple keys" do
    adapter.set("foo", "1")
    adapter.set("bar", "2")
    expect(subject.mget(["foo", "bar", "baz"])).to eq({
      "foo" => "1",
      "bar" => "2",
      "baz" => nil,
    })
  end

  it "raises error on set" do
    expect { subject.set("foo", "bar") }.to raise_error(Flipper::Adapters::ReadOnly::WriteAttempted)
  end

  it "raises error on del" do
    expect { subject.del("foo") }.to raise_error(Flipper::Adapters::ReadOnly::WriteAttempted)
  end
end
