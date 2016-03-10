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
        return modify_and_load_yamlfile(filepath) if File.readable?(filepath)
        raise HieraSimulator::FactLookupError, "Fact retriever could not find or access #{filepath}"
      end

      private

      # A typical Puppet YAML fact file looks like this:
      # ```
      # --- !ruby/object:Puppet::Node::Facts
      #   name: your.fqdn.com
      #   values:
      #     key1: val1
      #     key2: val2
      # ```
      # To avoid loading in all of Puppet just to parse what is basically a plain YAML file,
      # this method strips off the first line and un-indents all of the remaining lines to
      # make it a plain YAML file, and then parses that.
      # @param filepath [String] File Path to read
      # @return [Hash] Parsed YAML object
      def modify_and_load_yamlfile(filepath)
        content = File.read(filepath).split(/[\r\n]+/)
        first_line = content.shift
        unless first_line == '--- !ruby/object:Puppet::Node::Facts'
          raise HieraSimulator::FactSourceError, "#{filepath} was not in expected Puppet::Node::Facts format"
        end
        content.unshift '---'
        fixed_yaml = content.map { |line| line.sub(/^  /, '') }
        data = YAML.load(fixed_yaml.join("\n"))
        raise HieraSimulator::FactLookupError, "Invalid content in node fact file #{filepath}" unless data.key?('values')
        result = {}
        data['values'].each { |k, v| result['::' + k] = v }
        result
      end
    end
  end
end
