##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "uri"

module RDO
  # Abstract class that is subclassed by each specific driver.
  #
  # Driver developers should be able to subclass this, then write specs and
  # override the behaviours they need to change.
  #
  # Ideally all instance method will be overridden by really robust drivers.
  class Connection
    # Only instance methods should be overridden by subclasses.
    #
    # Class methods are generic utility methods.
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
      # @param [Connection] klass
      #   a subclass of RDO::Connection that provides the driver
      def register_driver(name, klass)
        drivers[name.to_s] = klass
      end

      # Initialize a new Connection.
      #
      # This method actually returns a subclass for the necessary driver.
      #
      # If no suitable driver is loaded, an RDO::Exception is raised.
      #
      # @param [Object] options
      #   either a connection URI, or a Hash of options
      #
      # @return [Connection]
      #   a Connection for the given options
      def new(options)
        # don't execute through subclasses
        return super if self < RDO::Connection

        options = normalize_options(options)

        unless drivers.key?(options[:driver])
          raise RDO::Exception, "Unregistered driver #{options[:driver].inspect}"
        end

        drivers[options[:driver]].new(options)
      end

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

      private

      def parse_connection_uri(str)
        uri = URI.parse(str.to_s)
        normalize_options(
          driver:   uri.scheme,
          host:     uri.host,
          port:     uri.port,
          database: uri.path.to_s.sub("/", ""),
          user:     uri.user,
          password: uri.password
        )
      end
    end

    # Options passed to initialize.
    attr_reader :options

    # Initialize the Connection with the given options.
    #
    # Subclasses SHOULD call super if overriding.
    # This method calls #open internally.
    #
    # @param [Hash] options
    #   all options passed to the Connection, as a Symbol-keyed Hash.
    #
    # @option [String] driver
    #   the name of the driver to use
    #   (usually the scheme portion of a connection URI)
    def initialize(options)
      @options = options.dup
      @open    = open or raise RDO::Exception,
        "Unable to establish connection, but the driver did not provide a reason"
    end

    # Open a connection to the RDBMS, if it is not already open.
    #
    # If it is not possible to open a connection, an RDO::Exception is raised.
    #
    # This is a no-op: subclasses MUST override this.
    #
    # @return [Boolean]
    #   true if a connection was opened or was already open, false if not.
    def open
      false
    end

    # Check if the connection is currently open or not.
    #
    # Some drivers MAY chose to override this.
    #
    # @return [Boolean]
    #   true if the connection is open, false otherwise
    def open?
      !!@open
    end

    # Close the current connection, if it is open.
    #
    # This is a no-op: subclasses MUST override this.
    #
    # @return [Boolean]
    #   true if the connection was closed or was already closed, false if not
    def close
      false
    end

    # Create a prepared statement to later be executed with some inputs.
    #
    # Not all drivers support this natively, but it is emulated by default.
    #
    # This is a default implementation for emulated prepared statements:
    # subclasses SHOULD override it if possible.
    #
    # @param [String] statement
    #   a string of SQL or DDL, with ? placeholders for bind parameters
    #
    # @return [Statement]
    #   a prepared statement to later be executed
    def prepare(statement)
      Statment.new(self, statement)
    end

    # Execute a statement against the RDBMS.
    #
    # The statement can either by a read, or a write operation.
    # Placeholders marked by `?' may be interpolated in the statement, so
    # that bind parameters can be safely provided.
    #
    # Where the RDBMS natively support bind parameters, this functionality is
    # used; otherwise, the values are quoted using #quote.
    #
    # This is a no-op: subclasses MUST override it.
    #
    # @param [String] statement
    #   a string of SQL or DDL to be executed
    #
    # @param [Array] *bind_values
    #   a list of parameters to substitute in the statement
    #
    # @return [Result]
    #   the result of the query
    def execute(statement, *bind_values)
    end

    # Escape a given value for safe interpolation into a statement.
    #
    # This should be avoided where the driver natively supports bind parameters.
    #
    # Subclasses SHOULD override this with a RDBMS-specific solution.
    #
    # @param [Object] value
    #   the value to quote
    #
    # @return [String]
    #   a safely escaped value
    def quote(value)
      value
    end
  end
end
