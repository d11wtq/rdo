##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

module RDO
  # This StatementExecutor is used as a fallback for prepared statements.
  #
  # If a DBMS driver does not implement prepared statements, this is used instead.
  # The #execute method simply delegates back to the driver.
  class EmulatedStatementExecutor
    attr_reader :command

    # Initialize a new statement executor for the given driver & command.
    #
    # @param [RDO::Driver] driver
    #   the Driver on which #prepare was invoked
    #
    # @param [String] command
    #   a string of SQL/DDL to execute
    def initialize(driver, command)
      @driver  = driver
      @command = command
    end

    # Execute the command using the given bind values.
    #
    # @param [Object...] args
    #   bind parameters to use in place of '?'
    def execute(*args)
      @driver.execute(command, *args)
    end
  end
end
