require 'yaml'

module HieraSimulator
  # Load the configuration for the Hiera simulator
  #
  # The order in which files are read in are:
  # - $CWD/.hiera-simulator.yaml
  # - $HOME/.hiera-simulator.yaml
  # - /etc/hiera-simulator.yaml
  #
  # The reading of the configuration values happens very much like in Hiera itself, where
  # the first time a key is seen, subsequent occurrences of that key are ignored.
  class Config
    attr_reader :config

    # Constructor
    # @param overrides [Hash] Override default settings for home_dir, global_config, and/or cwd
    def initialize(overrides = {})
      @home_dir = overrides.fetch(:home_dir, ENV['HOME'])
      @global_configfile = overrides.fetch(:global_config, '/etc/hiera-simulator.yaml')
      @working_dir = overrides.fetch(:cwd) { |_x| File.absolute_path(Dir.getwd) }
      @config = overrides.fetch(:config) { |_x| retrieve_config }
    end

    # Get - shorthand method to retrieve a particular key from the config hash
    # @param key [String] Key to retrieve
    # @param default [Object] Default value
    # @return [Object] Value of config setting
    def get(key, default = nil)
      @config.fetch(key, default)
    end

    # Merge! - Merge a hash
    # @param newhash [Hash] Hash to merge in
    def merge!(newhash)
      @config.merge!(newhash)
    end

    private

    # Read the configuration for the hiera simulator
    # @param overrides [Hash] Override default settings for home_dir, global_config, and/or cwd
    # @return [Hash] Merged configuration
    def retrieve_config
      result = {}
      filelist.each do |file|
        next unless File.file?(file)
        data = YAML.load_file(file)
        raise ConfigError, "File #{file} is not in the correct format. Expected hash got #{data.class}" unless data.is_a?(Hash)
        result = data.merge(result)
      end
      raise ConfigError, 'No local or global hiera-simulator config files contain config data' if result.empty?
      result
    end

    # From the overrides, get the file list
    # @return [Array<String>] File names of possible config files
    def filelist
      filename = '.hiera-simulator.yaml'
      files = []
      files << File.join(@working_dir, filename) unless @working_dir.nil?
      files << File.join(@home_dir, filename) unless @home_dir.nil?
      files << @global_configfile unless @global_configfile.nil?
      files
    end
  end

  class ConfigError < RuntimeError
    # Specific error handling for handled exceptions in this class
  end
end
