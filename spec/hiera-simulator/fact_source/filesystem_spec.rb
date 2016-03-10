require_relative '../spec_helper'

describe HieraSimulator::FactSource::FileSystem do
  before(:all) do
    @config = HieraSimulator::Config.new(
      global_config: HieraSimulator::Spec.gem_file('spec/fixtures/configfiles/hiera-simulator-filesystem.yaml'),
      cwd: nil,
      home_dir: nil
    )
  end

  describe '#new' do
    it 'Should return an error if fact directory is not specified' do
      options = { config: { this_is_empty: true } }
      config = HieraSimulator::Config.new(options)
      error_class = HieraSimulator::FactSourceError
      expect { HieraSimulator::FactSource::FileSystem.new(config) }.to raise_error(error_class)
    end
  end

  describe '#facts' do
    it 'Should raise error if it cannot find or read the file' do
      override = { fact_dir: HieraSimulator::Spec.gem_file('spec/fixtures/facts') }
      testobj = HieraSimulator::FactSource::FileSystem.new(@config, override)
      expect { testobj.facts('foonode') }.to raise_error(HieraSimulator::FactLookupError)
    end

    it 'Should raise error when attempting to load an invalid fact file' do
      override = { fact_dir: HieraSimulator::Spec.gem_file('spec/fixtures/facts') }
      testobj = HieraSimulator::FactSource::FileSystem.new(@config, override)
      expect { testobj.facts('invalid') }.to raise_error(HieraSimulator::FactSourceError)
    end

    it 'Should return the proper fact set when a valid node name is given' do
      override = { fact_dir: HieraSimulator::Spec.gem_file('spec/fixtures/facts') }
      testobj = HieraSimulator::FactSource::FileSystem.new(@config, override)
      result = testobj.facts('foobar.domain.com')
      expect(result['::application']).to eq('foobar application')
    end
  end
end
