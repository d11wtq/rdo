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
    def initialize(*args)
      super
      @colors = [35, 36]
      self.formatter = color_formatter
    end

    private

    def color_formatter
      Proc.new do |severity, time, prog, msg|
        case severity
        when "DEBUG"
          format_sql(msg)
        when "FATAL"
          format_err(msg)
        else
          "%s ~ %s" % [severity, msg]
        end + $/
      end
    end

    def format_sql(sql)
      a, b = @colors.reverse!
      "\033[#{a}mSQL\033[0m %s" % sql.sub(/\A(\(\d+\.\d+\))(.*)\Z/m, "\\1 \033[#{b}m~\033[0m \\2")
    end

    def format_err(msg)
      "\033[31mERROR ~ %s\033[0m" % msg
    end
  end
end
