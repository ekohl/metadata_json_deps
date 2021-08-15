require 'puppet_forge'
require 'puppet_metadata'

module MetadataJsonDeps
  class ForgeVersions
    def initialize(cache = {})
      @cache = cache
    end

    def get_module(name)
      name = PuppetForge::V3.normalize_name(name)
      @cache[name] ||= PuppetForge::Module.find(name)
    end
  end

  def self.build_fixtures(filename)
    require 'yaml'

    result = {}

    dependencies = PuppetMetadata.read(filename).dependencies
    if dependencies.any?
      forge = ForgeVersions.new

      repositories = {}
      result['fixtures'] = {'repositories' => repositories}

      dependencies.each do |dependency, _constraint|
        mod = forge.get_module(dependency)
        # TODO: The forge should expose the source URL directly
        repositories[mod.name] = mod.current_release.metadata[:source]
      end
    end

    puts result.to_yaml
  end

  def self.run(filenames, verbose = false)
    forge = ForgeVersions.new

    filenames.each do |filename|
      puts "Checking #{filename}"
      metadata = PuppetMetadata.read(filename)

      metadata.dependencies.map do |dependency, constraint|
        mod = forge.get_module(dependency)

        if mod.deprecated_at
          if mod.superseded_by
            puts "  #{dependency} was superseded by #{mod.superseded_by[:slug]}"
          elsif mod.deprecated_for
            puts "  #{dependency} was deprecated: #{mod.deprecated_for}"
          else
            puts "  #{dependency} was deprecated"
          end
        else
          current = mod.current_release.version

          if metadata.satisfies_dependency?(dependency, current)
            if verbose
              puts "  #{dependency} (#{constraint}) matches #{current}"
            end
          else
            puts "  #{dependency} (#{constraint}) doesn't match #{current}"
          end
        end
      end
    end
  rescue Interrupt
  end
end
