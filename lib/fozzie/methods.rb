require 'fozzie/connection'

module Fozzie
  module Methods

    def count(bucket, value, extra = nil)
      register(bucket, value, :c, extra)
    end

    def timer(bucket, value, unit, extra = nil)
      register(bucket, value, unit.to_sym, extra)
    end

    def sample(bucket, value, type, extra)
      case type.to_s
      when 'count' || 'c'
        extra = "@#{extra}" unless extra.nil?
        count(bucket, value, extra)
      else
        raise NotImplementedError
      end
    end

    private

    def register(bucket, value, type, extra = nil)
      send_data(create_key(bucket, value, type, extra))
      self
    end

    def send_data(data)
      Connection.send_data data
    end

    def create_key(bucket, value, type, extra)
      arr = [bucket, ":", value, "|", type]
      arr.push("|", extra) unless extra.nil?
      arr.join
    end

  end
end