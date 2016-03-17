require_relative '../spec_helper'

describe HieraSimulator::FactSource::Util do
  describe '#modify_and_load_yamlfile' do
    it 'Should correctly parse YAML file' do
      file = HieraSimulator::Spec.gem_file('spec/fixtures/facts/foobar.domain.com.yaml')
      result = HieraSimulator::FactSource::Util.modify_and_load_yamlfile(file)
      expect(result['::application']).to eq('foobar application')
      expect(result['::where-did-this-come-from']).to eq('filesystem.yaml')
    end
  end

  describe '#modify_and_load_jsonfile' do
    it 'Should correctly parse JSON file' do
      file = HieraSimulator::Spec.gem_file('spec/fixtures/facts/foobar.domain.com.json')
      result = HieraSimulator::FactSource::Util.modify_and_load_jsonfile(file)
      expect(result['::application']).to eq('foobar application')
      expect(result['::where-did-this-come-from']).to eq('filesystem.json')
    end
  end
end
