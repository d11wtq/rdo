##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "rdo/version"
require "rdo/exception"
require "rdo/connection"
require "rdo/result"
require "rdo/util"

module RDO
  class << self
    # Establish a connection to the RDBMS.
    #
    # The needed driver must be loaded before calling this.
    #
    # @param [Object] options
    #   either a connection URI string, or an option Hash
    #
    # @return [Connection]
    #   a Connection for the required driver
    def connect(options)
      Connection.new(options)
    end
  end
end
