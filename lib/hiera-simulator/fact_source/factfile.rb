require 'json'
require 'yaml'

module HieraSimulator
  module FactSource
    # Retrieve facts from a specified file on the file system.
    class FactFile
      # Constructor
      # @param config [HieraSimulator::Config] Config object
      def initialize(config, override = {})
        @fact_file = override.fetch(:fact_file, config.get('fact_file', nil))
        raise HieraSimulator::FactSourceError, 'No :fact_file was passed to FactFile' if @fact_file.nil?
      end

      # Get facts for a node
      # @param node [String] IGNORED
      # @param stringify_facts [Boolean] IGNORED
      # @return [Hash] Facts from the node in question
      def facts(node = nil)
        raise HieraSimulator::FactLookupError, "Invalid fact file specified: #{@fact_file}" unless File.file?(@fact_file)
        return HieraSimulator::FactSource::Util.modify_and_load_yamlfile(@fact_file) if @fact_file =~ /\.yaml$/
        return HieraSimulator::FactSource::Util.modify_and_load_jsonfile(@fact_file) if @fact_file =~ /\.json$/
        raise HieraSimulator::FactLookupError, "Unknown extension for: #{@fact_file}; .yaml and .json files are supported"
      end
    end
  end
end
