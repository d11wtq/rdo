require "rdo"

module RDO
  class DriverWithEverything < Driver
    class Executor
      def execute(*args)
        Result.new([])
      end
    end

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

    def prepare(stmt)
      Statement.new(Executor.new)
    end

    def quote(str)
      "quoted"
    end
  end

  Connection.register_driver(:rdo_with_all, DriverWithEverything)
end

