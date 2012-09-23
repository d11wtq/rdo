##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "uri"
require "forwardable"

module RDO
  # Wrapper class to manage Driver classes.
  #
  # This is the user-facing connection class. Users do not instantiate
  # drivers directly.
  class Connection
    class << self
      # List all known drivers, as a Hash mapping the URI scheme to the Class.
      #
      # @return [Hash]
      #   the mapping of driver names to class names
      def drivers
        @drivers ||= {}
      end

      # Register a known driver class for the given URI scheme name.
      #
      # @param [String] name
      #   the name of the URI scheme (e.g. sqlite)
      #
      # @param [Class<RDO::Driver>] klass
      #   a subclass of RDO::Driver that provides the driver
      def register_driver(name, klass)
        drivers[name.to_s] = klass
      end
    end

    extend Forwardable

    # Options passed to initialize.
    attr_reader :options

    # Most instance methods are delegated to the driver
    def_delegators :@driver, :open, :open?, :close, :execute, :prepare, :quote

    # Initialize a new Connection.
    #
    # This method instantiates the necessary driver.
    #
    # If no suitable driver is loaded, an RDO::Exception is raised.
    #
    # @param [Object] options
    #   either a connection URI, or a Hash of options
    #
    # @return [RDO::Connection]
    #   a Connection for the given options
    def initialize(options)
      @options = normalize_options(options)

      unless self.class.drivers.key?(@options[:driver])
        raise RDO::Exception,
          "Unregistered driver #{@options[:driver].inspect}"
      end

      @driver = self.class.drivers[options[:driver]].new(@options)
      @driver.open or raise RDO::Exception,
        "Unable to connect, but the driver did not provide a reason"
    end

    private

    # Normalizes the given options String or Hash into a Symbol-keyed Hash.
    #
    # @param [Object] options
    #   either a String, a URI or a Hash
    #
    # @return [Hash]
    #   a Symbol-keyed Hash
    def normalize_options(options)
      case options
      when Hash
        Hash[options.map{|k,v| [k.respond_to?(:to_sym) ? k.to_sym : k, v]}]
      when String, URI
        parse_connection_uri(options)
      else
        raise RDO::Exception,
          "Unsupported connection argument format: #{options.class.name}"
      end
    end

    def parse_connection_uri(str)
      uri = URI.parse(str.to_s)
      normalize_options(
        driver:   uri.scheme,
        host:     uri.host,
        port:     uri.port,
        path:     uri.path,
        database: uri.path.to_s.sub("/", ""),
        user:     uri.user,
        password: uri.password
      )
    end
  end
end
