require "pstore"
require "set"

module Flipper
  module Adapters
    # Public: Adapter based on Ruby's pstore database. Perfect for when a local
    # file is good enough for storing features.
    class PStore
      include ::Flipper::Adapter

      FeaturesKey = :flipper_features

      # Public: The name of the adapter.
      attr_reader :name

      # Public: The path to where the file is stored.
      attr_reader :path

      # Public
      def initialize(path = "flipper.pstore")
        @path = path
        @store = ::PStore.new(path)
        @name = :pstore
      end

      def get(key)
        @store.transaction do
          @store[key.to_s]
        end
      end

      # Private
      def set(key, value)
        @store.transaction do
          @store[key.to_s] = value.to_s
        end
      end

      # Private
      def del(key)
        @store.transaction do
          @store.delete(key.to_s)
        end
      end

      # Public
      def inspect
        attributes = [
          "name=#{@name.inspect}",
          "path=#{@path.inspect}",
          "store=#{@store}",
        ]
        "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
      end
    end
  end
end
