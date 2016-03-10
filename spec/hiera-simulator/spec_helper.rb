require_relative '../../lib/hiera-simulator'

module HieraSimulator
  class Spec
    # Base directory for the gem
    def self.gem_basedir
      File.expand_path('../..', File.dirname(__FILE__))
    end

    # File or directory in the gem
    def self.gem_file(path)
      File.join(gem_basedir, path.split('/'))
    end
  end
end
