module Flipper
  module Adapter
    SET_SEPARATOR = ",".freeze
    SET_SERIALIZER = lambda { |object| object.to_a.join(SET_SEPARATOR) }
    SET_DESERIALIZER = lambda { |raw| raw.to_s.split(SET_SEPARATOR).to_set }

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

    # Public: Override with data store specific implementation that is
    # more efficient/transactional.
    def smembers(key)
      sload(get(key))
    end

    # Public: Override with data store specific implementation that is
    # more efficient/transactional.
    def sadd(key, value)
      value = value.to_s
      members = smembers(key)

      if members.include?(value)
        false
      else
        members.add(value)
        set(key, sdump(members))
        true
      end
    end

    # Public: Override with data store specific implementation that is
    # more efficient/transactional.
    def srem(key, value)
      value = value.to_s
      members = smembers(key)

      if members.include?(value)
        members.delete(value)
        set(key, sdump(members))
        true
      else
        false
      end
    end

    # Public: Override with data store specific implementation that is
    # more efficient/transactional.
    def sdump(object)
      SET_SERIALIZER.call(object)
    end

    # Public: Override with data store specific implementation that is
    # more efficient/transactional.
    def sload(object)
      SET_DESERIALIZER.call(object)
    end
  end
end
