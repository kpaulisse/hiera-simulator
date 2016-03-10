require 'httparty'
require 'json'

module HieraSimulator
  module FactSource
    # Retrieve facts from PuppetDB. This object is a connection to a PuppetDB instance.
    class PuppetDB
      # Constructor
      # @param config [HieraSimulator::Config] Config object
      def initialize(config, override = {})
        @puppetdb_url = override.fetch(:puppetdb_url, config.get('puppetdb_url', nil))
        raise HieraSimulator::FactSourceError, 'No PuppetDB URL was found in hiera-simulator configuration' if @puppetdb_url.nil?
        @puppetdb_api_version = override.fetch(:puppetdb_api_version, config.get('puppetdb_api_version', 3))
        @httparty_timeout = override.fetch(:timeout, config.get('timeout', 10))
        @mock_puppetdb = override.fetch(:mock_puppetdb, config.get('mock_puppetdb', nil))
      end

      # Get facts for a node
      # @param node [String] Node FQDN as it should exist in PuppetDB
      # @return [Hash] Facts from the node in question
      def facts(node)
        return facts_v3(node) if @puppetdb_api_version == 3
        message = "HieraSimulator does not know how to handle PuppetDB API version #{@puppetdb_api_version}"
        raise HieraSimulator::FactSourceError, message
      end

      private

      # PuppetDB API v3
      def facts_v3(source)
        reply = response("/v3/nodes/#{source}/facts")
        result = {}
        reply.each { |x| result['::' + x['name']] = x['value'] }
        result
      end

      # HTTP(S) Query
      # @param path [String] Path portion of the URL
      # @return [Hash] Facts from the node in question
      def response(path)
        return mocked_response(@mock_puppetdb) unless @mock_puppetdb.nil?
        complete_url = @puppetdb_url + path
        options = {
          timeout: @httparty_timeout
        }
        begin
          x = HTTParty.get(complete_url, options).parsed_response
          raise HieraSimulator::FactLookupError, "PuppetDB resource not found: #{complete_url}" if x == 'Not Found'
          return x
        rescue Net::OpenTimeout => e
          raise HieraSimulator::FactSourceError, "PuppetDB connection timeout: #{e.message}"
        rescue Errno::ECONNREFUSED => e
          raise HieraSimulator::FactSourceError, "PuppetDB connection refused: #{e.message}"
        end
      end

      # Mock puppetdb response, for spec testing
      def mocked_response(filepath)
        JSON.parse(File.read(filepath))
      end
    end
  end
end
