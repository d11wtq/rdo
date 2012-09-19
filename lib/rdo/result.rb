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

    def each(&block)
      self
    end
  end
end
