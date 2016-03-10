require_relative 'spec_helper'

describe HieraSimulator::Config do
  describe '#new' do
    it 'Should raise an error if a configuration file is not a hash' do
      options = {
        home_dir: nil,
        global_config: HieraSimulator::Spec.gem_file('spec/fixtures/configfiles/bad-config.yaml'),
        cwd: nil
      }
      expect { HieraSimulator::Config.new(options) }.to raise_error(HieraSimulator::ConfigError)
    end

    it 'Should raise a ConfigError if there are not any files found' do
      options = {
        home_dir: HieraSimulator::Spec.gem_file('spec/fixtures/configfiles/empty'),
        global_config: HieraSimulator::Spec.gem_file('spec/fixtures/configfiles/empty/this-does-not-exist'),
        cwd: nil
      }
      expect { HieraSimulator::Config.new(options) }.to raise_error(HieraSimulator::ConfigError)
    end
  end

  describe '#retrieve_config' do
    it 'Should merge options in the correct order (working dir > home dir > global file)' do
      options = {
        home_dir: File.join(HieraSimulator::Spec.gem_basedir, 'spec', 'fixtures', 'configfiles2'),
        global_config: HieraSimulator::Spec.gem_file('spec/fixtures/configfiles/hiera-simulator.yaml'),
        cwd: File.join(HieraSimulator::Spec.gem_basedir, 'spec', 'fixtures', 'configfiles')
      }
      testobj = HieraSimulator::Config.new(options)
      result = testobj.config
      expect(result['cat']).to eq('meow')
      expect(result['cow']).to eq('moo')
      expect(result['duck']).to eq('quack')
      expect(result['turkey']).to eq('gobble')
      expect(result['chicken']).to eq('cluck')
    end
  end

  describe '#get' do
    it 'Should return the correct value when defined' do
      options = {
        home_dir: File.join(HieraSimulator::Spec.gem_basedir, 'spec', 'fixtures', 'configfiles'),
        global_config: nil,
        cwd: nil
      }
      testobj = HieraSimulator::Config.new(options)
      expect(testobj.get('cat', 'not defined')).to eq('meow')
    end

    it 'Should return the default value when undefined' do
      options = {
        home_dir: File.join(HieraSimulator::Spec.gem_basedir, 'spec', 'fixtures', 'configfiles'),
        global_config: nil,
        cwd: nil
      }
      testobj = HieraSimulator::Config.new(options)
      expect(testobj.get('fish', 'no sound under water')).to eq('no sound under water')
    end
  end
end
