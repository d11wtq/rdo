##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "logger"

module RDO
  # A Logger that outputs using color to highlight errors etc.
  class ColoredLogger < Logger
    def initialize(*)
      super
      self.formatter =
        Proc.new do |severity, time, prog, msg|
          case severity
          when "DEBUG" then "\033[35mSQL\033[0m \033[36m~\033[0m %s#{$/}" % msg
          when "FATAL" then "\033[31mERROR ~ %s\033[0m#{$/}" % msg
          else "%s ~ %s#{$/}" % [severity, msg]
          end
        end
    end
  end
end
