require_relative '../spec_helper'

describe HieraSimulator::FactSource::PuppetDB do
  before(:all) do
    @config = HieraSimulator::Config.new(
      global_config: HieraSimulator::Spec.gem_file('spec/fixtures/configfiles/hiera-simulator-puppetdb.yaml'),
      cwd: nil,
      home_dir: nil
    )
  end

  describe '#new' do
    it 'Should raise an error if no PuppetDB URL is specified' do
      options = {
        global_config: HieraSimulator::Spec.gem_file('spec/fixtures/configfiles/hiera-simulator.yaml'),
        cwd: nil,
        home_dir: nil
      }
      config = HieraSimulator::Config.new(options)
      expect { HieraSimulator::FactSource::PuppetDB.new(config) }.to raise_error(HieraSimulator::FactSourceError)
    end
  end

  describe '#facts' do
    it 'Should raise PuppetDBError if invalid PuppetDB API version is detected' do
      override = { puppetdb_api_version: -100 }
      testobj = HieraSimulator::FactSource::PuppetDB.new(@config, override)
      expect { testobj.facts('foonode') }.to raise_error(HieraSimulator::FactSourceError)
    end
  end

  describe '#response' do
    it 'Should return connection refused if unable to connect to PuppetDB' do
      override = { puppetdb_url: 'http://127.0.0.1:1', timeout: 3 }
      testobj = HieraSimulator::FactSource::PuppetDB.new(@config, override)
      time_start = Time.now.to_i
      expect { testobj.facts('foonode') }.to raise_error(HieraSimulator::FactSourceError)
      time_diff = Time.now.to_i - time_start
      expect(time_diff).to be <= 1, "PuppetDB took too long to return connection refused: #{time_diff}"
    end

    it 'Should time out if unable to connect to PuppetDB' do
      override = { puppetdb_url: 'http://127.0.0.254:1', timeout: 0.25 }
      testobj = HieraSimulator::FactSource::PuppetDB.new(@config, override)
      time_start = Time.now.to_i
      expect { testobj.facts('foonode') }.to raise_error(HieraSimulator::FactSourceError)
      time_diff = Time.now.to_i - time_start
      expect(time_diff).to be <= 1, "PuppetDB took too long to time out: #{time_diff}"
    end
  end

  describe '#facts_v3' do
    it 'Should add the leading :: to all fact names' do
      filepath = HieraSimulator::Spec.gem_file('spec/fixtures/puppetdb/v3/foobar.domain.com.txt')
      testobj = HieraSimulator::FactSource::PuppetDB.new(@config, mock_puppetdb: filepath, puppetdb_api_version: 3)
      result = testobj.facts('foonode')
      expect(result.key?('::kernel')).to be true
      expect(result.key?('kernel')).to be false
      expect(result['::kernel']).to eq('Linux')
    end
  end
end
