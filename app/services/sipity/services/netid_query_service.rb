require 'open-uri'
module Sipity
  module Services
    # Responsible for querying people API server to get more details for netid
    class NetidQueryService
      # We encountered an issue in which we needed to temporarily disable SSL verification
      # When we need to disable SSL verification, use this method.
      # @see .read
      def self.read_without_ssl_verification(url:)
        open(url, ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE).read
      end

      # Under normal circumstances, we want to use standard OpenURI read method.
      # @see .read_without_ssl_verification
      def self.read(url:)
        open(url).read
      end

      def self.preferred_name(netid)
        new(netid).preferred_name
      end

      def self.valid_netid?(netid)
        new(netid).valid_netid?
      end

      def initialize(netid, url_reader: self.class.method(:read_without_ssl_verification))
        self.netid = netid
        self.url_reader = url_reader
      end

      attr_reader :netid, :url_reader

      private

      attr_writer :url_reader

      def netid=(input)
        @netid = input.to_s.strip
      end

      public

      # @return [netid] if the input is not a valid NetID
      # @return [String] if the input is a valid NetID
      def preferred_name
        person.fetch('full_name')
      rescue KeyError
        netid
      end

      # @return [false] if the input is not a valid NetID
      # @return [String] if the input is a valid NetID
      def valid_netid?
        person.fetch('netid')
      rescue KeyError
        false
      end

      private

      def person
        return {} unless netid.present?
        parse
      rescue OpenURI::HTTPError
        {}
      end

      def response
        url_reader.call(url: url)
      end

      def parse
        JSON.parse(response).fetch('people').first
      end

      def url(env: Figaro.env)
        base_uri = URI.parse(env.hesburgh_api_host!)
        base_uri.path = "/1.0/people/by_netid/#{netid}.json"
        base_uri.query = "auth_token=#{env.hesburgh_api_auth_token!}"
        base_uri.to_s
      end
    end
  end
end
