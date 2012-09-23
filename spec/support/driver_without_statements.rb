require "rdo"

module RDO
  class DriverWithoutStatements < Driver
    def open
      @open = true
    end

    def open?
      !!@open
    end

    def close
      !(@open = false)
    end

    def execute(stmt, *args)
      Result.new([])
    end
  end

  Connection.register_driver(:rdo_without_stmt, DriverWithoutStatements)
end
