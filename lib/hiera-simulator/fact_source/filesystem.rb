require 'tempfile'
require 'yaml'

module HieraSimulator
  module FactSource
    # Retrieve facts from the file system. This object is a "connection" to those files.
    class FileSystem
      # Constructor
      # @param config [HieraSimulator::Config] Config object
      def initialize(config, override = {})
        @fact_dir = override.fetch(:fact_dir, config.get('fact_dir', nil))
        raise HieraSimulator::FactSourceError, 'No fact_dir was found in hiera-simulator configuration' if @fact_dir.nil?
      end

      # Get facts for a node
      # @param node [String] Node FQDN as it should exist in PuppetDB
      # @return [Hash] Facts from the node in question
      def facts(node)
        filepath = File.join(@fact_dir, node + '.yaml')
        return HieraSimulator::FactSource::Util.modify_and_load_yamlfile(filepath) if File.readable?(filepath)
        raise HieraSimulator::FactLookupError, "Fact retriever could not find or access #{filepath}"
      end
    end
  end
end
