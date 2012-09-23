##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "forwardable"

module RDO
  # Represents a prepared statement.
  #
  # This class actually just wraps a StatementExecutor,
  # which only needs to conform to a duck-type
  class Statement
    extend Forwardable

    def_delegators :@executor, :connection, :command, :execute

    # Initialize a new Statement wrapping the given StatementExecutor.
    #
    # @param [Object] executor
    #   any object that responds to #execute, #connection and #command
    def initialize(executor)
      @executor = executor
    end
  end
end
