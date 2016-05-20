module Flipper
  module Adapters
    # Public: Adapter that wraps another adapter and raises for any writes.
    class ReadOnly
      include ::Flipper::Adapter

      class WriteAttempted < Error
        def initialize(message = nil)
          super(message || "write attempted while in read only mode")
        end
      end

      # Internal: The name of the adapter.
      attr_reader :name

      # Public
      def initialize(adapter)
        @adapter = adapter
        @name = :read_only
      end

      def features
        @adapter.features
      end

      def get(key)
        @adapter.get(key)
      end

      def set(key, value)
        raise WriteAttempted
      end

      def del(key)
        raise WriteAttempted
      end
    end
  end
end
