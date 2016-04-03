require_relative 'spec_helper'

describe HieraSimulator::HieraLookup do
  before(:all) do
    @options_yaml_structured = {
      config: {
        'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-yaml-structured.yaml'),
        'yaml_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierayaml')
      }
    }
    @options_yaml_unstructured = {
      config: {
        'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-yaml-unstructured.yaml'),
        'yaml_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierayaml')
      }
    }
    @options_json_structured = {
      config: {
        'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-json-structured.yaml'),
        'json_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierajson')
      }
    }
    @options_json_unstructured = {
      config: {
        'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-json-unstructured.yaml'),
        'json_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierajson')
      }
    }
  end

  describe '#lookup' do
    it 'Should successfully look up a value from first choice directory (YAML)' do
      config = HieraSimulator::Config.new(@options_yaml_unstructured)
      facts = {
        '::fqdn' => 'foobaz.domain.com',
        '::datacenter' => 'east'
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('servers/foobaz.domain.com')
    end

    it 'Should successfully look up a value from second choice directory (YAML)' do
      config = HieraSimulator::Config.new(@options_yaml_unstructured)
      facts = {
        '::fqdn' => 'foobar.domain.com',
        '::datacenter' => 'east'
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('datacenter/east')
    end

    it 'Should successfully look up a value from common file (YAML)' do
      config = HieraSimulator::Config.new(@options_yaml_unstructured)
      facts = {
        '::fqdn' => 'foobar.domain.com',
        '::datacenter' => 'central'
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('common')
    end

    it 'Should return nil when a value is not found' do
      config = HieraSimulator::Config.new(@options_yaml_unstructured)
      facts = {
        '::fqdn' => 'foobar.domain.com',
        '::datacenter' => 'central'
      }
      result = HieraSimulator::HieraLookup.lookup('this-key-does-not-exist-anywhere', config, facts)
      expect(result).to be nil
    end

    it 'Should work correctly with the JSON backend' do
      config = HieraSimulator::Config.new(@options_json_unstructured)
      facts = {
        '::fqdn' => 'foobar.domain.com',
        '::datacenter' => 'east'
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('datacenter/east')
    end

    it 'Should work correctly with non-stringified facts' do
      pending('This only works with hiera >= 2') if Hiera.version.to_i < 2
      config = HieraSimulator::Config.new(@options_yaml_structured)
      facts = {
        'fqdn' => 'foobar.domain.com',
        'datacenter' => 'central',
        'os' => {
          'architecture' => 'amd64',
          'distro' => {
            'codename' => 'trusty',
            'description' => 'Ubuntu 14.04.2 LTS',
            'id' => 'Ubuntu'
          }
        }
      }
      result = HieraSimulator::HieraLookup.lookup('what-file-is-this', config, facts)
      expect(result).to eq('os/Ubuntu/trusty')
    end
  end
end
