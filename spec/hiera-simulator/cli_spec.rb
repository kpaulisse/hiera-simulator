require_relative 'spec_helper'

# These are integration tests

describe HieraSimulator::Cli do
  describe '#cli' do
    it 'Should correctly look up a simulated fact with PuppetDB v3 fact backend' do
      options = {
        hostname: 'foobar.domain.com',
        key: 'what-file-is-this'
      }
      config = {
        home_dir: nil,
        global_config: nil,
        cwd: nil,
        config: {
          'mock_puppetdb' => HieraSimulator::Spec.gem_file('spec/fixtures/puppetdb/v3/foobar.domain.com.txt'),
          'puppetdb_url' => 'http://127.0.0.1:1',
          'puppetdb_api_version' => 3,
          'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-yaml-unstructured.yaml'),
          'yaml_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierayaml')
        }
      }
      answer = HieraSimulator::Cli.execute(options, config)
      expect(answer).to eq('datacenter/east')
    end

    it 'Should correctly look up a simulated fact with PuppetDB v4 structured fact backend' do
      pending('This only works with hiera >= 2') if Hiera.version.to_i < 2
      
      options = {
        hostname: 'foobar.domain.com',
        key: 'what-file-is-this'
      }
      config = {
        home_dir: nil,
        global_config: nil,
        cwd: nil,
        config: {
          'mock_puppetdb' => HieraSimulator::Spec.gem_file('spec/fixtures/puppetdb/v4/foobar.domain.com.txt'),
          'puppetdb_url' => 'http://127.0.0.1:1',
          'puppetdb_api_version' => 4,
          'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-yaml-structured.yaml'),
          'yaml_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierayaml')
        }
      }
      answer = HieraSimulator::Cli.execute(options, config)
      expect(answer).to eq('os/Ubuntu/trusty')

      answer = HieraSimulator::Cli.execute(options.merge({key: 'what-datacenter-is-this'}), config)
      expect(answer).to eq('east')
    end

    it 'Should correctly look up a simulated fact with PuppetDB v4 un-structured fact backend' do
      options = {
        hostname: 'foobar.domain.com',
        key: 'what-file-is-this'
      }
      config = {
        home_dir: nil,
        global_config: nil,
        cwd: nil,
        config: {
          'mock_puppetdb' => HieraSimulator::Spec.gem_file('spec/fixtures/puppetdb/v4/foobar.domain.com.txt'),
          'puppetdb_url' => 'http://127.0.0.1:1',
          'puppetdb_api_version' => 4,
          'stringify_facts' => true,
          'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-yaml-unstructured.yaml'),
          'yaml_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierayaml')
        }
      }
      answer = HieraSimulator::Cli.execute(options, config)
      expect(answer).to eq('os/Ubuntu/trusty')

      answer = HieraSimulator::Cli.execute(options.merge({key: 'what-datacenter-is-this'}), config)
      expect(answer).to eq('east')
    end
  end
end
