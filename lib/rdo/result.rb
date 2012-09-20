##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

module RDO
  # The standard Result class returned by Connection#execute.
  #
  # Both read and write queries receive results in this format.
  class Result
    include Enumerable

    # Initialize a new Result.
    #
    # @param [Enumerable] tuples
    #   a list of tuples, provided by the driver
    #
    # @param [Hash] info
    #   information about the result, including:
    #   - count
    #   - rows_affected
    #   - insert_id
    #   - execution_time
    def initialize(tuples, info = {})
      @info   = info.dup
      @tuples = tuples
    end

    # Get raw result info provided by the driver.
    #
    # @return [Hash]
    #   aribitrary information provided about the result
    def info
      @info
    end

    # Get the number of rows in the result.
    #
    # Many drivers provide the count, otherwise it will be computed at runtime.
    #
    # @return Fixnum
    #   the number of rows in the Result
    def count
      if info[:count].nil? || block_given?
        super
      else
        info[:count]
      end
    end

    # Iterate over all rows returned by the connection.
    #
    # For each row, a Symbol-keyed Hash is yielded into the block.
    def each(&block)
      tap{ @tuples.each(&block) }
    end
  end
end
