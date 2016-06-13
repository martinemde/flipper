# Requires the following methods:
# * subject - The instance of the adapter
shared_examples_for 'a flipper adapter' do
  let(:actor_class) { Struct.new(:flipper_id) }

  let(:flipper) { Flipper.new(subject) }
  let(:feature) { flipper[:stats] }

  let(:boolean_gate) { feature.gate(:boolean) }
  let(:group_gate)   { feature.gate(:group) }
  let(:actor_gate)   { feature.gate(:actor) }
  let(:actors_gate)  { feature.gate(:percentage_of_actors) }
  let(:time_gate)  { feature.gate(:percentage_of_time) }

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
    subject.set("foo", "1")
    subject.set("bar", "2")
    expect(subject.mget(["foo", "bar", "baz"])).to eq({
      "foo" => "1",
      "bar" => "2",
      "baz" => nil,
    })
  end

  it "returns nil for each missing key when getting multiple keys" do
    expect(subject.mget(["foo", "bar", "baz"])).to eq({
      "foo" => nil,
      "bar" => nil,
      "baz" => nil,
    })
  end

  it "can set a key" do
    subject.set("foo", "bar")
    expect(subject.get("foo")).to eq("bar")
  end

  it "always sets value to string" do
    subject.set("foo", 22)
    expect(subject.get("foo")).to eq("22")
  end

  it "can set multiple keys" do
    subject.mset({
      "foo" => "1",
      "bar" => "2",
    })
    expect(subject.mget(["foo", "bar"])).to eq({
      "foo" => "1",
      "bar" => "2",
    })
  end

  it "always msets values to strings" do
    subject.mset({
      "foo" => 1,
      "bar" => 2,
    })
    expect(subject.mget(["foo", "bar"])).to eq({
      "foo" => "1",
      "bar" => "2",
    })
  end

  it "can delete a key" do
    subject.set("foo", "1")
    expect(subject.get("foo")).to eq("1")
    subject.del("foo")
    expect(subject.get("foo")).to be(nil)
  end

  it "can delete multiple keys" do
    subject.set("foo", "1")
    subject.set("bar", "2")
    subject.set("baz", "3")
    expect(subject.mget(["foo", "bar", "baz"])).to eq({
      "foo" => "1",
      "bar" => "2",
      "baz" => "3",
    })
    subject.mdel(["foo", "bar"])
    expect(subject.mget(["foo", "bar", "baz"])).to eq({
      "foo" => nil,
      "bar" => nil,
      "baz" => "3",
    })
  end

  it "can add, remove and read set members" do
    expect(subject.smembers("foo")).to eq(Set.new)

    expect(subject.sadd("foo", "1")).to be(true)
    expect(subject.smembers("foo")).to eq(Set["1"])

    # read from a different set that should still be empty
    expect(subject.smembers("bar")).to eq(Set.new)

    expect(subject.sadd("foo", "2")).to be(true)
    expect(subject.smembers("foo")).to eq(Set["1", "2"])

    expect(subject.sadd("foo", "3")).to be(true)
    expect(subject.smembers("foo")).to eq(Set["1", "2", "3"])

    expect(subject.srem("foo", "3")).to be(true)
    expect(subject.smembers("foo")).to eq(Set["1", "2"])

    expect(subject.srem("foo", "2")).to be(true)
    expect(subject.smembers("foo")).to eq(Set["1"])

    expect(subject.srem("foo", "1")).to be(true)
    expect(subject.smembers("foo")).to eq(Set.new)
  end

  it "doesn't add value if already in set" do
    expect(subject.sadd("foo", "1")).to be(true)
    expect(subject.sadd("foo", "1")).to be(false)
    expect(subject.smembers("foo")).to eq(Set["1"])
  end

  it "doesn't remove value if not in set" do
    expect(subject.srem("foo", "1")).to be(false)
  end
end
