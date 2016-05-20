require 'set'

module Flipper
  module Adapters
    # Public: Adapter for storing everything in memory (ie: Hash).
    # Useful for tests/specs.
    class Memory
      include ::Flipper::Adapter

      attr_reader :name

      def initialize(source = nil)
        @source = source || {}
        @name = :memory
      end

      def get(key)
        @source[key]
      end

      def set(key, value)
        @source[key] = value.to_s
        true
      end

      def del(key)
        @source.delete(key)
        true
      end

      # Public
      def inspect
        attributes = [
          "name=:memory",
          "source=#{@source.inspect}",
        ]
        "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
      end
    end
  end
end
