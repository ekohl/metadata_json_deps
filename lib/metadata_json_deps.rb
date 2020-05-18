require 'puppet_forge'
require 'puppet_metadata'
require 'semantic_puppet'

module MetadataJsonDeps
  class ForgeVersions
    def initialize(cache = {})
      @cache = cache
    end

    def get_current_version(name)
      name = name.sub('/', '-')
      @cache[name] ||= get_version(get_mod(name))
    end

    private

    def get_mod(name)
      PuppetForge::Module.find(name)
    end

    def get_version(mod)
      SemanticPuppet::Version.parse(mod.current_release.version)
    end
  end

  def self.run(filenames, verbose = false)
    forge = ForgeVersions.new

    filenames.each do |filename|
      puts "Checking #{filename}"
      metadata = PuppetMetadata.read(filename)

      metadata.dependencies.map do |dependency, constraint|
        current = forge.get_current_version(dependency)

        if constraint.include?(current)
          if verbose
            puts "  #{dependency} (#{constraint}) matches #{current}"
          end
        else
          puts "  #{dependency} (#{constraint}) doesn't match #{current}"
        end
      end
    end
  rescue Interrupt
  end
end
