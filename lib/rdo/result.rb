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

    # Return the inserted row ID.
    #
    # For some drivers this requires that a RETURNING clause by used in SQL.
    # It may be more desirable to simply check the rows in the result.
    #
    # @return [Object]
    #   the ID of the record just inserted, or nil
    def insert_id
      if info.key?(:insert_id)
        info[:insert_id]
      else
        first_value
      end
    end

    # If only one column and one row is expected in the result, fetch it.
    #
    # If no rows were returned, this method returns nil.
    #
    # @return [Object]
    #   a single value at the first column in the first row of the result
    def first_value
      if row = first
        row.values.first
      end
    end

    # Return the number of rows affected by the query.
    #
    # @return [Fixnum]
    #   the number of rows affected
    def affected_rows
      info[:affected_rows].to_i
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
        info[:count].to_i
      end
    end

    # Check if the result has no rows.
    #
    # @return [Boolean]
    #   true if the result has no returned rows
    def empty?
      count.zero?
    end

    # Get the time spent processing the statement.
    #
    # @return [Float]
    #   the time in seconds spent executing the query
    def execution_time
      info[:execution_time].to_f
    end

    # Iterate over all rows returned by the connection.
    #
    # For each row, a Symbol-keyed Hash is yielded into the block.
    def each(&block)
      tap{ @tuples.each(&block) }
    end
  end
end
