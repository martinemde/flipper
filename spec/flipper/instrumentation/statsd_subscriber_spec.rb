require 'helper'
require 'flipper/adapters/memory'
require 'flipper/instrumentation/statsd'

RSpec.describe Flipper::Instrumentation::StatsdSubscriber do
  let(:statsd_client) { Statsd.new }
  let(:socket) { FakeUDPSocket.new }
  let(:adapter) { Flipper::Adapters::Memory.new }
  let(:flipper) {
    Flipper.new(adapter, :instrumenter => ActiveSupport::Notifications)
  }

  let(:user) { user = Struct.new(:flipper_id).new('1') }

  before do
    described_class.client = statsd_client
    Thread.current[:statsd_socket] = socket
  end

  after do
    described_class.client = nil
    Thread.current[:statsd_socket] = nil
  end

  def assert_timer(metric)
    regex = /#{Regexp.escape metric}\:\d+\|ms/
    result = socket.buffer.detect { |op| op.first =~ regex }
    expect(result).not_to be_nil
  end

  def assert_counter(metric)
    result = socket.buffer.detect { |op| op.first == "#{metric}:1|c" }
    expect(result).not_to be_nil
  end

  context "for enabled feature" do
    it "updates feature metrics when calls happen" do
      flipper[:stats].enable(user)
      assert_timer 'flipper.feature_operation.enable'

      flipper[:stats].enabled?(user)
      assert_timer 'flipper.feature_operation.enabled'
      assert_counter 'flipper.feature.stats.enabled'
    end
  end

  context "for disabled feature" do
    it "updates feature metrics when calls happen" do
      flipper[:stats].disable(user)
      assert_timer 'flipper.feature_operation.disable'

      flipper[:stats].enabled?(user)
      assert_timer 'flipper.feature_operation.enabled'
      assert_counter 'flipper.feature.stats.disabled'
    end
  end
end
