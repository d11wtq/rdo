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
  # The #execute method simply delegates back to the connection object.
  class EmulatedStatementExecutor
    attr_reader :command
    attr_reader :connection

    # Initialize a new statement executor for the given connection & command.
    #
    # @param [RDO::Connection] connection
    #   the connection on which #prepare was invoked
    #
    # @param [String] command
    #   a string of SQL/DDL to execute
    def initialize(connection, command)
      @connection = connection
      @command    = command
    end

    # Execute the command using the given bind values.
    #
    # @param [Object...] args
    #   bind parameters to use in place of '?'
    def execute(*args)
      connection.execute(command, *args)
    end
  end
end
