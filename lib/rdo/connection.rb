##
# RDO: Ruby Data Objects.
# Copyright © 2012 Chris Corbyn.
#
# See LICENSE file for details.
##

require "uri"
require "cgi"
require "logger"
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

    # A Logger (from ruby stdlib)
    attr_accessor :logger

    # Most instance methods are delegated to the driver
    def_delegators :@driver, :open, :open?, :close, :quote

    # Initialize a new Connection.
    #
    # This method instantiates the necessary driver.
    #
    # If no suitable driver is loaded, an RDO::Exception is raised.
    #
    # @param [Object] uri
    #   either a connection URI string, or an options Hash
    #
    # @param [Hash] options
    #   if a URI is provided for the first argument, additional options may
    #   be specified here. These may override settings in the first argument.
    #
    # @return [RDO::Connection]
    #   a Connection for the given options
    def initialize(uri, options = {})
      @options = normalize_options(uri).merge(normalize_options(options))
      @logger  = @options.fetch(:logger, null_logger)

      unless self.class.drivers.key?(@options[:driver])
        raise RDO::Exception,
          "Unregistered driver #{@options[:driver].inspect}"
      end

      @driver = self.class.drivers[@options[:driver]].new(@options)
      @driver.open or raise RDO::Exception,
        "Unable to connect, but the driver did not provide a reason"
    end

    # Execute a statement with the configured Driver.
    #
    # The statement can either be a read, or a write operation.
    # Placeholders marked by '?' may be interpolated in the statement, so
    # that bind parameters can be safely provided.
    #
    # Where the RDBMS natively supports bind parameters, this functionality is
    # used; otherwise, the values are quoted using #quote.
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
      t = Time.now
      @driver.execute(statement, *bind_values).tap do |rs|
        rs.info[:execution_time] ||= Time.now - t
        if logger.debug?
          logger.debug(
            "(%.6fs) %s%s" % [
              rs.execution_time,
              statement,
              ("<Bind: #{bind_values.inspect}>" unless bind_values.empty?)
            ]
          )
        end
      end
    rescue RDO::Exception => e
      logger.fatal(e.message) if logger.fatal?
      raise
    end

    # Create a prepared statement to later be executed with some inputs.
    #
    # Not all drivers support this natively, but it is emulated by default.
    #
    # @param [String] statement
    #   a string of SQL or DDL, with '?' placeholders for bind parameters
    #
    # @return [Statement]
    #   a prepared statement to later be executed
    def prepare(command)
      Statement.new(@driver.prepare(command), logger)
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
        Hash[options.map{|k,v| [k.respond_to?(:to_sym) ? k.to_sym : k, v]}].tap do |opts|
          opts[:driver] = opts[:driver].to_s if opts[:driver]
        end
      when String, URI
        parse_connection_uri(options)
      else
        raise RDO::Exception,
          "Unsupported connection argument format: #{options.class.name}"
      end
    end

    def parse_connection_uri(str)
      uri = # handle e.g. sqlite: and sqlite:// (empty host and path)
        if str =~ %r{\A[a-z0-9_\+-]+:\Z}i
          URI.parse(str.to_s + "//rdo-spoof").tap{|u| u.host = nil}
        elsif str =~ %r{\A[a-z0-9_\+-]+://\Z}i
          URI.parse(str.to_s + "rdo-spoof").tap{|u| u.host = nil}
        else
          URI.parse(str.to_s)
        end

      normalize_options(
        {
          driver:   uri.scheme,
          host:     uri.host,
          port:     uri.port,
          path:     extract_uri_path(uri),
          database: extract_uri_path(uri).to_s.sub("/", ""),
          user:     uri.user,
          password: uri.password
        }.merge(parse_query_string(extract_uri_query(uri)))
      )
    end

    def extract_uri_path(uri)
      return uri.path unless uri.opaque
      uri.opaque.sub(/\?.*\Z/, "")
    end

    def extract_uri_query(uri)
      return uri.query unless uri.opaque
      uri.opaque.sub(/\A.*?\?/, "")
    end

    def parse_query_string(str)
      str.nil? ? {} : Hash[CGI.parse(str).map{|k,v| [k, v.size == 1 ? v.first : v]}]
    end

    def null_logger
      Logger.new(RDO::DEV_NULL).tap{|l| l.level = Logger::UNKNOWN}
    end
  end
end
