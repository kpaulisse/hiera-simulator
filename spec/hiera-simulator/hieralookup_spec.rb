require_relative 'spec_helper'

describe HieraSimulator::HieraLookup do
  before(:all) do
    @options_yaml = {
      config: {
        'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-yaml.yaml'),
        'yaml_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierayaml')
      }
    }
    @options_json = {
      config: {
        'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-json.yaml'),
        'json_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierajson')
      }
    }
  end

  describe '#lookup' do
    it 'Should successfully look up a value from first choice directory (YAML)' do
      config = HieraSimulator::Config.new(@options_yaml)
      facts = {
        '::fqdn' => 'foobaz.domain.com',
        '::datacenter' => 'east'
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('servers/foobaz.domain.com')
    end

    it 'Should successfully look up a value from second choice directory (YAML)' do
      config = HieraSimulator::Config.new(@options_yaml)
      facts = {
        '::fqdn' => 'foobar.domain.com',
        '::datacenter' => 'east'
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('datacenter/east')
    end

    it 'Should successfully look up a value from common file (YAML)' do
      config = HieraSimulator::Config.new(@options_yaml)
      facts = {
        '::fqdn' => 'foobar.domain.com',
        '::datacenter' => 'central'
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('common')
    end

    it 'Should return nil when a value is not found' do
      config = HieraSimulator::Config.new(@options_yaml)
      facts = {
        '::fqdn' => 'foobar.domain.com',
        '::datacenter' => 'central'
      }
      result = HieraSimulator::HieraLookup.lookup('this-key-does-not-exist-anywhere', config, facts)
      expect(result).to be nil
    end

    it 'Should work correctly with the JSON backend' do
      config = HieraSimulator::Config.new(@options_json)
      facts = {
        '::fqdn' => 'foobar.domain.com',
        '::datacenter' => 'east'
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('datacenter/east')
    end
  end
end
