module Sipity
  module Services
    # Responsible for minting a single noid
    #
    # @see https://githbub.com/ndlib/noids
    class NoidMinter
      # While you can pass the configuration, the first time is what matters, as
      # it sets the minter and caches the minter.
      #
      # @note There is a critical assumption in this implimentation that the
      #       named pool already exists in the noid server. This is because we
      #       use the same pool for CurateND, CurateND's batch system, and
      #       Sipity.
      #
      # @return [String] a unique noid (from the configured pool)
      # @see #initialize for parameteres
      def self.call(**kwargs)
        @minter ||= new(**kwargs)
        @minter.call
      end

      # @param kwargs [Hash] a hash or list of keyword args
      # @option kwargs [String] :server - the named server (http://localhost)
      #            that host the noid
      # @option kwargs [#to_i] :port - the port to connect for the named server
      # @option kwargs [String] :pool_name - the name of the pool from which to
      #            mint a pid
      # @option kwargs [NoidsClient::Connection] :connection_class - added for
      #            dependency injection to ease testing.
      def initialize(**kwargs)
        @server = kwargs.fetch(:server, Figaro.env.noid_server!)
        @port = kwargs.fetch(:port, Figaro.env.noid_port!)
        @pool_name = kwargs.fetch(:pool_name, Figaro.env.noid_pool!)
        @connection_class = kwargs.fetch(:connection_class) { default_connection_class }
        establish_connection!
      end
      attr_reader :server, :port, :pool_name, :pool, :connection, :connection_class

      def call
        @pool ||= connection.get_pool(pool_name)
        @pool.mint.first
      end

      private

      def default_connection_class
        require 'noids_client'
        ::NoidsClient::Connection
      end

      def establish_connection!
        @connection = connection_class.new("#{server}:#{port}")
      end
    end
  end
end
