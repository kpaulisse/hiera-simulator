describe HieraSimulator::Facts do
  before(:all) do
    @options = {
      config: {
        'mock_puppetdb' => HieraSimulator::Spec.gem_file('spec/fixtures/puppetdb/v3/foobar.domain.com.txt'),
        'puppetdb_url' => 'http://127.0.0.1:1',
        'puppetdb_api_version' => 3,
        'fact_dir' => HieraSimulator::Spec.gem_file('spec/fixtures/facts')
      }
    }
  end

  describe '#facts' do
    it 'Should use the PuppetDB backend when configured to do so' do
      options = {}
      options[:config] = @options[:config].dup
      options[:config][:backends] = ['PuppetDB']
      config = HieraSimulator::Config.new(options)
      result = HieraSimulator::Facts.facts(config, 'foobar.domain.com')
      expect(result['::application']).to eq('foobar application')
      expect(result['::where-did-this-come-from']).to eq('puppetdb')
    end

    it 'Should use the FileSystem backend when configured to do so' do
      options = {}
      options[:config] = @options[:config].dup
      options[:config][:backends] = ['FileSystem']
      config = HieraSimulator::Config.new(options)
      result = HieraSimulator::Facts.facts(config, 'foobar.domain.com')
      expect(result['::application']).to eq('foobar application')
      expect(result['::where-did-this-come-from']).to eq('filesystem')
    end

    it 'Should first try the FileSystem if backend is not explicitly set' do
      config = HieraSimulator::Config.new(@options)
      result = HieraSimulator::Facts.facts(config, 'foobar.domain.com')
      expect(result['::application']).to eq('foobar application')
      expect(result['::where-did-this-come-from']).to eq('filesystem')
    end
  end
end
