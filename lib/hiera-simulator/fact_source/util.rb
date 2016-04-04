require 'json'
require 'yaml'

module HieraSimulator
  module FactSource
    # Some handy methods that may be used by multiple fact sources
    class Util
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
      def self.modify_and_load_yamlfile(filepath)
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

      # A typical fact file (e.g., from PuppetDB) looks like this:
      # {
      #   "key1": "value1",
      #   "key2": "value2"
      # }
      # This reads the fact file and returns a hash with the facts in the proper format.
      # @param filepath [String] File Path to read
      # @return [Hash] Parsed YAML object
      def self.modify_and_load_jsonfile(filepath)
        data = JSON.parse(File.read(filepath))
        result = {}
        data.each { |k, v| result['::' + k] = v }
        result
      end

      # Stringify key-value, needed for some older versions of Puppet and hiera
      # @param name [String] current key
      # @param value [Object] current value
      # @param prior [String] prior value, for recursion
      # @return [Array<[name, value]>] Stringified facts and values
      def self.stringify(name, value, prior = '::' + name)
        return [[ prior.sub(/::$/, ''), value ]] unless value.is_a?(Hash)
        result = []
        value.each do |k, v|
          result.concat stringify(k, v, prior + '::' + k)
        end
        result
      end
    end
  end
end
