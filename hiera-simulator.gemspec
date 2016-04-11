Gem::Specification.new do |s|
  s.name        = 'hiera-simulator'
  s.version     = '0.2.2'
  s.authors     = 'Kevin Paulisse'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.homepage    = 'http://github.com/kpaulisse/hiera-simulator'
  s.summary     = 'Determine what hiera would output for a set of facts'
  s.description = 'Used to pre-test changes in a Puppet codebase'
  s.license     = 'Apache 2.0'

  s.files         = Dir['[A-Z]*[^~]'] + Dir['lib/**/*.rb'] + Dir['spec/*'] + ['bin/hiera-simulator']
  s.test_files    = Dir['spec/*']
  s.executables   = ['hiera-simulator']
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rake'
  s.add_runtime_dependency 'bundler'
  s.add_runtime_dependency 'hiera'
  s.add_runtime_dependency 'httparty' # Connecting to puppetdb
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'deep_merge' # Needed by hiera but not included in its gem spec

  s.add_development_dependency 'rspec', '>= 3.0.0'
end
