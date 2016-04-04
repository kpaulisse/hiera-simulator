require 'hiera/version'
require 'optparse'
require 'pp'

module HieraSimulator
  # Command Line Interface
  class Cli
    # Drive the command line interface - this is called externally
    def self.run(options_in = nil, config_in = {})
      options = options_in.nil? ? parse_options : options_in
      answer = execute(options, config_in)
      exit print_answer(answer, options)
    end

    # Handle command line interface
    def self.execute(options, config_in)
      config = HieraSimulator::Config.new(config_in)
      command_line_override(options, config)
      config.validate
      facts = HieraSimulator::Facts.facts(config, options[:hostname], options[:stringify_facts])
      raise "No facts found for host #{options[:hostname]}" if facts.empty?
      hiera_options = { resolution_type: options[:resolution_type], verbose: options[:verbose] }
      HieraSimulator::HieraLookup.lookup(options[:key], config, facts, hiera_options)
    end

    # Print answer
    def self.print_answer(answer, options)
      STDERR.puts "Hiera version = #{Hiera::VERSION}" if options[:verbose]
      if answer.nil?
        puts 'nil'
        return 1
      elsif answer.is_a?(String)
        puts answer
      else
        pp answer
      end
      0
    end

    # Overrides from command line
    def self.command_line_override(options, config)
      merges = {}
      [:hiera_yaml_path, :json_datadir, :yaml_datadir, :factdir, :fact_file].each do |key|
        merges[key.to_s] = options[key] if options.key?(key) && !options[key].nil?
      end
      config.merge!(merges) unless merges.empty?
    end

    # Parse command line options
    # @return [Hash] Parsed (command line) options
    def self.parse_options
      result = {
        verbose: false,
        resolution_type: :priority,
        hostname: nil,
        fact_file: nil,
        stringify_facts: nil,
      }
      OptionParser.new do |opts|
        opts.banner = 'Usage: hiera-simulator -n <Node_FQDN> [options] key'

        opts.on('--hiera-yaml-path PATH', 'Path to hiera.yaml file') do |path|
          dir = find_dir(File.dirname(path))
          result[:hiera_yaml_path] = File.absolute_path(File.join(dir, File.basename(path)))
          raise Errno::ENOENT, 'The specified hiera.yaml file does not exist' unless File.file?(result[:hiera_yaml_path])
        end

        opts.on('--yaml-datadir DIR', 'YAML data directory') do |datadir|
          result[:yaml_datadir] = find_dir(datadir)
        end

        opts.on('--json-datadir DIR', 'JSON data directory') do |datadir|
          result[:json_datadir] = find_dir(datadir)
        end

        opts.on('-d', '--debug', 'Turn on Hiera debugging/verbose mode') do
          result[:verbose] = true
        end

        opts.on('--hostname FQDN', '-n', 'Use facts from last run of FQDN') do |fqdn|
          result[:hostname] = fqdn
        end

        opts.on('--fact-file PATH', 'Use facts from the specified file (.yaml/.json only)') do |path|
          result[:fact_file] = path
          result[:hostname] = '.' if result[:hostname].nil?
        end

        opts.on('--factsdir DIR', '-f', 'Base directory of YAML facts') do |factdir|
          result[:factdir] = find_dir(factdir)
        end

        opts.on('--puppetdb', '-p', 'Force lookup of facts in puppetdb') do |puppetdb|
          result[:puppetdb] = puppetdb
        end

        opts.on('--array', 'Return answer as an array') do
          result[:resolution_type] = :array
        end

        opts.on('--hash', 'Return answer as an hash') do
          result[:resolution_type] = :hash
        end

        opts.on('--[no-]stringify-facts', 'Override default stringify facts behavior') do |x|
          result[:stringify_facts] = x
        end
      end.parse!

      if ARGV.empty?
        puts 'ERROR: You did not specify a data item to look up!'
        exit 1
      end

      if result[:hostname].nil?
        puts 'ERROR: You did not specify a host name to simulate (-n <hostname>)'
        exit 1
      end

      result[:key] = ARGV.delete_at(0)
      result
    end

    # Find a user-supplied directory, either absolute path, or relative to the current
    # working directory. If directory cannot be find, raise exception.
    # @param dir [String] Directory name supplied by user
    # @return [String] Absolute path to confirmed existing directory
    def self.find_dir(dir)
      result = []
      dir_array = dir.is_a?(Array) ? dir : [dir]
      dir_array.each do |dir_ent|
        if File.directory?(dir_ent)
          result << File.absolute_path(dir_ent)
        elsif File.directory?(File.join(File.absolute_path(Dir.getwd), factdir))
          result << File.join(File.absolute_path(Dir.getwd), dir_ent)
        else
          raise Errno::ENOENT, "Specified directory #{dir_ent} does not exist or is inaccessible"
        end
      end
      return result[0] unless dir.is_a?(Array)
      result
    end
  end
end
