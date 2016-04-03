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
        @stringify_facts = determine_stringify_facts(override, config)
      end

      # Get facts for a node
      # @param node [String] Node FQDN as it should exist in PuppetDB
      # @return [Hash] Facts from the node in question
      def facts(node)
        return facts_v3(node) if @puppetdb_api_version == 3
        return facts_v4(node) if @puppetdb_api_version == 4
        message = "HieraSimulator does not know how to handle PuppetDB API version #{@puppetdb_api_version}"
        raise HieraSimulator::FactSourceError, message
      end

      # Stringify key-value, needed until we upgrade our ancient version of hiera
      def stringify(name, value, prior = '::' + name)
        return [[ prior.sub(/::$/, ''), value ]] unless value.is_a?(Hash)
        result = []
        value.each do |k, v|
          result.concat stringify(k, v, prior + '::' + k)
        end
        result
      end

      private

      def determine_stringify_facts(override, config)
        return override.fetch(:stringify_facts) if override.key?(:stringify_facts)
        default = false
        default = true if @puppetdb_api_version <= 3
        default = true if Hiera.version.to_i < 2
        config.get('stringify_facts', default)
      end

      # PuppetDB API common
      def facts_common(uri)
        reply = response(uri)

        # Stringify facts if needed (old hiera, old PuppetDB)
        if @stringify_facts
          result = {}
          reply.each do |x|
            stringify(x['name'], x['value']).each do |y|
              result[y[0]] = y[1]
            end
          end
          return result
        end

        # Don't stringify facts
        result = {}
        reply.map { |x| result[x['name']] = x['value'] }
        result
      end

      # PuppetDB API v3
      def facts_v3(source)
        facts_common("/v3/nodes/#{source}/facts")
      end

      # PuppetDB API v4
      def facts_v4(source)
        facts_common("/pdb/query/v4/nodes/#{source}/facts")
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
