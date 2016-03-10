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
          'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-yaml.yaml'),
          'yaml_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierayaml')
        }
      }
      answer = HieraSimulator::Cli.execute(options, config)
      expect(answer).to eq('datacenter/east')
    end

    it 'Should correctly look up a simulated fact with YAML fact backend' do
      options = {
        hostname: 'foobar.domain.com',
        key: 'what-file-is-this'
      }
      config = {
        home_dir: nil,
        global_config: nil,
        cwd: nil,
        config: {
          'fact_dir' => HieraSimulator::Spec.gem_file('spec/fixtures/facts'),
          'hiera_yaml_path' => HieraSimulator::Spec.gem_file('spec/fixtures/hiera/hiera-yaml.yaml'),
          'yaml_datadir' => HieraSimulator::Spec.gem_file('spec/fixtures/hierayaml')
        }
      }
      answer = HieraSimulator::Cli.execute(options, config)
      expect(answer).to eq('datacenter/east')
    end
  end
end
