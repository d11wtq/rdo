##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "rdo/version"
require "rdo/exception"
require "rdo/driver"
require "rdo/connection"
require "rdo/statement"
require "rdo/emulated_statement_executor"
require "rdo/result"
require "rdo/util"
require "rdo/colored_logger"

# c extension
require "rdo/rdo"

module RDO
  class << self
    # Establish a connection to the RDBMS.
    # The connection will be returned open.
    #
    # The needed driver must be loaded before calling this.
    #
    # If a block is given, the connection is passed to the block and then
    # closed at the end of the block, before this method finally returns
    # the result of the block.
    #
    # @param [Object] uri
    #   either a connection URI string, or an options Hash
    #
    # @param [Hash] options
    #   if a URI is provided for the first argument, additional options may
    #   be specified here. These may override settings in the first argument.
    #
    # @return [Connection]
    #   a Connection for the required driver
    def connect(uri, options = {})
      if block_given?
        begin
          c = Connection.new(uri, options)
          yield c
        ensure
          c.close unless c.nil?
        end
      else
        Connection.new(uri, options)
      end
    end

    alias_method :open, :connect
  end

  # A suitable NULL device for writing nothing
  DEV_NULL =
    if defined? IO::NULL
      IO::NULL
    else
      ENV["OS"] =~ /Windows/ ? "NUL" : "/dev/null"
    end
end
