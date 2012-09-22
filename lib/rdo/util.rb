##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "date"
require "bigdecimal"

module RDO
  # This file contains methods useful for drivers to convert complex types.
  #
  # Performing these operations in C would not be any cheaper, since the data
  # must first be converted into Ruby types anyway.
  module Util
    class << self
      # Convert a String to a Float, taking into account Infinity and NaN.
      #
      # @param [String] s
      #   a String that is formatted for a Float;
      #   or Infinity, -Infinity or NaN.
      #
      # @return [Float]
      #   a Float that is the same as the input
      def float(s)
        case s
        when "Infinity"
          Float::INFINITY
        when "-Infinity"
          -Float::INFINITY
        when "NaN"
          Float::NAN
        else
          Float(s)
        end
      end

      # Convert a String to a BigDecimal.
      #
      # @param [String] s
      #   a String that is formatted as a decimal, or NaN
      #
      # @return [BigDecimal]
      #   the BigDecimal representation of this number
      def decimal(s)
        BigDecimal(s)
      end

      # Convert a date & time string, without a time zone, into a DateTime.
      #
      # This method will parse the DateTime using the system time zone.
      #
      # @param [String] s
      #   a date & time string
      #
      # @return [DateTime]
      #   a DateTime in the system time zone
      def date_time_without_zone(s)
        date_time_with_zone(s + system_time_zone)
      end

      # Convert a date & time string, with a time zone, into a DateTime.
      #
      # @param [String] s
      #   a date & time string, including a time zone
      #
      # @return [DateTime]
      #   a DateTime for this input
      def date_time_with_zone(s)
        DateTime.parse(s)
      end

      # Convert a date string into a Date.
      #
      # This method understands AD and BC.
      #
      # @param [String] s
      #   a string representing a date, possibly BC
      #
      # @return [Date]
      #   a Date for this input
      def date(s)
        Date.parse(s)
      end

      # Get the time zone of the local system.
      #
      # This is useful—in fact crucial—for ensuring times are represented
      # correctly.
      #
      # Driver developers should use this, where possible, to notify the DBMS
      # of the client's time zone.
      #
      # @return [String]
      #   a string of the form '+10:00', or '-09:30'
      def system_time_zone
        DateTime.now.zone
      end
    end
  end
end
