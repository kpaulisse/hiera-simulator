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

  describe '#stringify' do
    it 'Should not touch values that are not a hash' do
      facts = {
        'number-one' => 1,
        'false'      => false,
        'a-string'   => 'kittens',
      }
      facts.each do |name, value|
        result = HieraSimulator::FactSource::Util.stringify(name, value)
        expect(result.size).to eq(1)
        expect(result[0][0]).to eq('::' + name)
        expect(result[0][1]).to eq(value)
      end
    end

    it 'Should stringify a hash' do
      facts = {
        'number-one' => 1,
        'kittens' => {
          'eyecolor' => {
            'siamese' => 'blue',
            'tabby' => 'green'
          }
        }
      }
      test_result = {}
      facts.each do |name, value|
        HieraSimulator::FactSource::Util.stringify(name, value).each do |y|
          test_result[y[0]] = y[1]
        end
      end
      expect(test_result.key?('::kittens')).to eq(false)
      expect(test_result.key?('kittens')).to eq(false)
      expect(test_result.key?('::kittens::eyecolor::siamese')).to eq(true)
      expect(test_result['::kittens::eyecolor::siamese']).to eq('blue')
    end
  end
end
