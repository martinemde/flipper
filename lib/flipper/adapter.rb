module Flipper
  module Adapter
    # adding a module include so we have some hooks for stuff down the road

    # Public: Override with data store specific implementation that is
    # more efficient/transactional.
    def mget(keys)
      hash = {}
      keys.each do |key|
        hash[key] = get(key)
      end
      hash
    end

    # Public: Override with data store specific implementation that is
    # more efficient/transactional.
    def mset(kvs)
      kvs.each do |key, value|
        set(key, value)
      end

      true
    end

    # Public: Override with data store specific implementation that is
    # more efficient/transactional.
    def mdel(keys)
      keys.each { |key| del(key) }

      true
    end
  end
end
