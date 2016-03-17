raise 'Error: hiera-simulator requires Ruby >= 2.0.0' if RUBY_VERSION < '2.0.0'
Dir["#{File.dirname(__FILE__)}/hiera-simulator/**/*.rb"].each { |f| require(f) }
