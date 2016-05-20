module Flipper
  module Adapters
    # Public: Adapter that wraps another adapter and stores the operations.
    #
    # Useful in tests to verify calls and such. Never use outside of testing.
    class OperationLogger
      include ::Flipper::Adapter

      Operation = Struct.new(:type, :args)

      OperationTypes = [
        :features,
        :add,
        :remove,
        :clear,
        :get,
        :enable,
        :disable,
      ]

      # Internal: An array of the operations that have happened.
      attr_reader :operations

      # Internal: The name of the adapter.
      attr_reader :name

      # Public
      def initialize(adapter, operations = nil)
        @adapter = adapter
        @name = :operation_logger
        @operations = operations || []
      end

      def get(key)
        @operations << Operation.new(:get, [key])
        @adapter.get(key)
      end

      def mget(keys)
        @operations << Operation.new(:mget, [keys])
        @adapter.mget(keys)
      end

      def set(key, value)
        @operations << Operation.new(:set, [key, value])
        @adapter.set(key, value)
      end

      def mset(kvs)
        @operations << Operation.new(:mset, [kvs])
        @adapter.mset(kvs)
      end

      def del(key)
        @operations << Operation.new(:del, [key])
        @adapter.del(key)
      end

      def mdel(keys)
        @operations << Operation.new(:mdel, [keys])
        @adapter.mdel(keys)
      end

      # Public: Count the number of times a certain operation happened.
      def count(type)
        @operations.select { |operation| operation.type == type }.size
      end

      # Public: Resets the operation log to empty
      def reset
        @operations.clear
      end
    end
  end
end
