module HieraSimulator
  # Gather facts from the specified backend(s)
  class Facts
    # Constructor
    # @param config [HieraSimulator::Config] Configuration object
    def self.facts(config, node, stringify_facts = nil)
      override = {}
      override[:stringify_facts] = stringify_facts unless stringify_facts.nil?
      errors = []
      backends = config.get(:backends, %w(FileSystem PuppetDB))
      backends = ['FactFile'] unless config.get('fact_file', nil).nil?
      backends.each do |backend|
        begin
          obj = Module.const_get("HieraSimulator::FactSource::#{backend}").new(config, override)
          return obj.facts(node)
        rescue HieraSimulator::FactSourceError, HieraSimulator::FactLookupError => exc
          errors << { exception: exc, backend: backend }
          next
        end
      end
      raise "Unable to retrieve facts for #{node}:\n#{format_errors(errors)}"
    end

    def self.format_errors(error_array)
      error_array.map { |x| "- #{x[:backend]}: #{x[:exception]}" }.join("\n")
    end
  end

  class FactLookupError < RuntimeError
    # Catch handled exceptions from data source
  end

  class FactSourceError < RuntimeError
    # Catch handled exceptions from data source
  end
end
