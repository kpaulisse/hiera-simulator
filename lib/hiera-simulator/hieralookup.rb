require 'hiera'
require 'hiera/util'
require 'tempfile'

module HieraSimulator
  # Actually interact with the Hiera gem
  class HieraLookup
    # Look up a key in hiera
    # @param key [String] Key to look up
    # @param config [HieraSimulator::Config] Configuration object
    # @param verbose [Boolean] Enable verbose mode for hiera
    def self.lookup(key, config, facts, options = {})
      hiera_tmp_config = generate_hiera_file(config)
      hiera = Hiera.new(config: hiera_tmp_config)
      Hiera.logger = options.fetch(:verbose, false) ? 'console' : 'noop'
      result = hiera.lookup(key, nil, facts, nil, options.fetch(:resolution_type, :priority))
      File.unlink(hiera_tmp_config)
      result
    end

    # Generate a temporary hiera configuration file, adjusting for directory paths
    # in a local development environment.
    def self.generate_hiera_file(config)
      hiera_yaml_path = config.get('hiera_yaml_path', '(undefined)')
      raise Errno::ENOENT, "Cannot open hiera_yaml_path '#{hiera_yaml_path}'" unless File.file?(hiera_yaml_path)
      hiera_cfg = YAML.load_file(hiera_yaml_path)

      backends = config.get('backends', hiera_cfg[:backends])
      hiera_cfg[:backends] = backends unless backends == 'preserve'

      if hiera_cfg[:backends].include?('yaml')
        yaml_datadir = config.get('yaml_datadir', nil)
        config.raise_missing_parameter 'yaml_datadir' if yaml_datadir.nil?
        hiera_cfg[:yaml] = { datadir: yaml_datadir }
      end

      if hiera_cfg[:backends].include?('json')
        json_datadir = config.get('json_datadir', nil)
        config.raise_missing_parameter 'json_datadir' if json_datadir.nil?
        hiera_cfg[:json] = { datadir: json_datadir }
      end

      other_backends = hiera_cfg[:backends] - ['yaml','json']
      if other_backends.any?
        STDERR.puts "WARNING: Ignoring unsupported backend(s): #{other_backends.join(', ')}"
        hiera_cfg[:backends] = hiera_cfg[:backends] & ['yaml', 'json']
      end

      hiera_file = Tempfile.new('hiera.yaml')
      hiera_file.write hiera_cfg.to_yaml
      hiera_file.close
      hiera_file.path
    end
  end
end
