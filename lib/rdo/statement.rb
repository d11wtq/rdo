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

    def_delegators :@executor, :command

    # Initialize a new Statement wrapping the given StatementExecutor.
    #
    # @param [Object] executor
    #   any object that responds to #execute, #connection and #command
    def initialize(executor, logger)
      @executor = executor
      @logger   = logger
    end

    # Execute the command using the given bind values.
    #
    # @param [Object...] args
    #   bind parameters to use in place of '?'
    def execute(*bind_values)
      @executor.execute(*bind_values).tap do
        if logger.debug?
          logger.debug("#{command}#{" <Bind: #{bind_values.inspect}>" unless bind_values.empty?}")
        end
      end
    rescue RDO::Exception => e
      logger.fatal(e.message) if logger.fatal?
      raise
    end

    private

    def logger
      @logger
    end
  end
end
