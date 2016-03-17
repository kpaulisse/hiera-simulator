require_relative '../spec_helper'

describe HieraSimulator::FactSource::FactFile do
  before(:all) do
    @config = HieraSimulator::Config.new(
      global_config: HieraSimulator::Spec.gem_file('spec/fixtures/configfiles/hiera-simulator-filesystem.yaml'),
      cwd: nil,
      home_dir: nil
    )
  end

  describe '#new' do
    it 'Should raise error if :fact_file override is not specified' do
      expect { HieraSimulator::FactSource::FactFile.new(@config, {}) }.to raise_error(HieraSimulator::FactSourceError)
    end

    it 'Should accept a fact_file coming in via the config object' do
      config = HieraSimulator::Config.new(
        config: {
          'fact_file' => HieraSimulator::Spec.gem_file('spec/fixtures/facts/foobar.domain.com.yaml')
        }
      )
      testobj = HieraSimulator::FactSource::FactFile.new(config)
      result = testobj.facts
      expect(result['::application']).to eq('foobar application')
      expect(result['::where-did-this-come-from']).to eq('filesystem.yaml')
    end
  end

  describe '#facts' do
    it 'Should handle YAML file' do
      filepath = HieraSimulator::Spec.gem_file('spec/fixtures/facts/foobar.domain.com.yaml')
      testobj = HieraSimulator::FactSource::FactFile.new(@config, fact_file: filepath)
      result = testobj.facts
      expect(result['::application']).to eq('foobar application')
      expect(result['::where-did-this-come-from']).to eq('filesystem.yaml')
    end

    it 'Should handle JSON file' do
      filepath = HieraSimulator::Spec.gem_file('spec/fixtures/facts/foobar.domain.com.json')
      testobj = HieraSimulator::FactSource::FactFile.new(@config, fact_file: filepath)
      result = testobj.facts
      expect(result['::application']).to eq('foobar application')
      expect(result['::where-did-this-come-from']).to eq('filesystem.json')
    end

    it 'Should raise error if file is not found' do
      filepath = HieraSimulator::Spec.gem_file('spec/fixtures/empty/this-file-does-not-exist.yaml')
      testobj = HieraSimulator::FactSource::FactFile.new(@config, fact_file: filepath)
      expect { testobj.facts }.to raise_error(HieraSimulator::FactLookupError)
    end

    it 'Should raise error for unknown extension' do
      filepath = HieraSimulator::Spec.gem_file('spec/fixtures/empty/empty.txt')
      testobj = HieraSimulator::FactSource::FactFile.new(@config, fact_file: filepath)
      expect { testobj.facts }.to raise_error(HieraSimulator::FactLookupError)
    end
  end
end
