##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

module RDO
  # Abstract class that is subclassed by each specific driver.
  #
  # Driver developers should be able to subclass this, then write specs and
  # override the behaviours they need to change.
  #
  # Ideally all instance method will be overridden by really robust drivers.
  class Driver
    # Options passed to initialize.
    attr_reader :options

    # Initialize the Driver with the given options.
    #
    # Drivers SHOULD call super if overriding.
    #
    # @param [Hash] options
    #   all options passed to the Driver, as a Symbol-keyed Hash.
    def initialize(options = {})
      @options = options.dup
    end

    # Open a connection to the RDBMS, if it is not already open.
    #
    # If it is not possible to open a connection, an RDO::Exception is raised.
    #
    # This is a no-op: subclasses MUST override this.
    #
    # @return [Boolean]
    #   true if a connection was opened or was already open, false if not.
    def open
      false
    end

    # Check if the connection is currently open or not.
    #
    # Drivers MUST override this.
    #
    # @return [Boolean]
    #   true if the connection is open, false otherwise
    def open?
      false
    end

    # Close the current connection, if it is open.
    #
    # Drivers MUST override this.
    #
    # @return [Boolean]
    #   true if the connection was closed or was already closed, false if not
    def close
      false
    end

    # Create a prepared statement to later be executed with some inputs.
    #
    # Not all drivers support this natively, but it is emulated by default.
    #
    # This is a default implementation for emulated prepared statements:
    # drivers SHOULD override it if possible.
    #
    # @param [String] statement
    #   a string of SQL or DDL, with '?' placeholders for bind parameters
    #
    # @return [Statement]
    #   a prepared statement to later be executed
    def prepare(statement)
      Statement.new(emulated_statement_executor(statement))
    end

    # Execute a statement against the RDBMS.
    #
    # The statement can either by a read, or a write operation.
    # Placeholders marked by '?' may be interpolated in the statement, so
    # that bind parameters can be safely provided.
    #
    # Where the RDBMS natively support bind parameters, this functionality is
    # used; otherwise, the values are quoted using #quote.
    #
    # Drivers MUST override this.
    #
    # @param [String] statement
    #   a string of SQL or DDL to be executed
    #
    # @param [Array] *bind_values
    #   a list of parameters to substitute in the statement
    #
    # @return [Result]
    #   the result of the query
    def execute(statement, *bind_values)
      Result.new([])
    end

    # Escape a given value for safe interpolation into a statement.
    #
    # This should be avoided where the driver natively supports bind parameters.
    #
    # Drivers MUST override this with a RDBMS-specific solution.
    #
    # @param [Object] value
    #   the value to quote
    #
    # @return [String]
    #   a safely escaped value
    def quote(value)
    end

    private

    def emulated_statement_executor(stmt)
      EmulatedStatementExecutor.new(self, stmt)
    end
  end
end
