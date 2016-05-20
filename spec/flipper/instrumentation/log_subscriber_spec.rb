require 'logger'
require 'helper'
require 'flipper/adapters/memory'
require 'flipper/instrumentation/log_subscriber'

RSpec.describe Flipper::Instrumentation::LogSubscriber do
  let(:adapter) { Flipper::Adapters::Memory.new }
  let(:flipper) {
    Flipper.new(adapter, :instrumenter => ActiveSupport::Notifications)
  }

  before do
    Flipper.register(:admins) { |thing|
      thing.respond_to?(:admin?) && thing.admin?
    }

    @io = StringIO.new
    logger = Logger.new(@io)
    logger.formatter = proc { |severity, datetime, progname, msg| "#{msg}\n" }
    described_class.logger = logger
  end

  after do
    described_class.logger = nil
  end

  let(:log) { @io.string }

  context "feature enabled checks" do
    before do
      clear_logs
      flipper[:search].enabled?
    end

    it "logs feature calls with result after operation" do
      feature_line = find_line('Flipper feature(search) enabled? false')
      expect(feature_line).to include('[ thing=nil ]')
    end
  end

  context "feature enabled checks with a thing" do
    let(:user) { Flipper::Types::Actor.new(Struct.new(:flipper_id).new('1')) }

    before do
      clear_logs
      flipper[:search].enabled?(user)
    end

    it "logs thing for feature" do
      feature_line = find_line('Flipper feature(search) enabled?')
      expect(feature_line).to include(user.inspect)
    end
  end

  context "changing feature enabled state" do
    let(:user) { Flipper::Types::Actor.new(Struct.new(:flipper_id).new('1')) }

    before do
      clear_logs
      flipper[:search].enable(user)
    end

    it "logs feature calls with result in brackets" do
      feature_line = find_line('Flipper feature(search) enable true')
      expect(feature_line).to include("[ thing=#{user.inspect} gate_name=actor ]")
    end
  end

  def find_line(str)
    regex = /#{Regexp.escape(str)}/
    lines = log.split("\n")
    lines.detect { |line| line =~ regex } ||
      raise("Could not find line matching #{str.inspect} in #{lines.inspect}")
  end

  def clear_logs
    @io.string = ''
  end
end
