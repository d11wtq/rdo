require "rdo"

module RDO
  class DriverWithBackwardsQuote < Driver
    def open
      @open = true
    end

    def open?
      !!@open
    end

    def close
      @open = false
      true
    end

    def execute(stmt, *args)
      Result.new([])
    end

    def quote(obj)
      obj.to_s.reverse
    end
  end

  Connection.register_driver(:rdo_with_backwards_quote, DriverWithBackwardsQuote)
end

