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

  # Bump a dependency in a filename
  #
  # @param [String] filename A path to a metadata file. An error is raised if
  #   it's invalid metadata.
  # @param [String] module_name The module name listed in dependencies. It must
  #   be normalized to the forge style (using a dash). It can fall back to a
  #   slash if metadata uses a slash.
  # @param [String] upper_bound The new upper bound for the module name
  # @return [Array<String>] An array with the old and new version. Can be used
  #   to determine if a change was made.
  # @see PuppetMetadata.read
  def self.bump_dependency(filename, module_name, upper_bound)
    metadata = PuppetMetadata.read(filename)

    requirement = metadata.dependencies[module_name]
    unless requirement
      # TODO: normalize keys in puppet_metadata so we don't need 2 lookups?
      module_name = module_name.tr('-', '/')
      requirement = metadata.dependencies[module_name]
      raise Exception.new("Dependency #{module_name} not found") unless requirement
    end

    return [requirement.to_s, requirement.to_s] if requirement.end == upper_bound

    new = ">= #{requirement.begin} < #{upper_bound}"

    new_metadata = metadata.metadata.clone
    new_metadata['dependencies'].each do |dependency|
      if dependency['name'] == module_name
        dependency['version_requirement'] = new
      end
    end

    File.write(filename, JSON.pretty_generate(new_metadata) + "\n")

    [requirement.to_s, new]
  end

  def self.run(filenames, verbose = false)
    forge = ForgeVersions.new

    exit_code = 0

    filenames.each do |filename|
      puts "Checking #{filename}"
      metadata = PuppetMetadata.read(filename)

      metadata.dependencies.map do |dependency, constraint|
        mod = forge.get_module(dependency)

        if mod.deprecated_at
          exit_code |= 2
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
            exit_code |= 1
            puts "  #{dependency} (#{constraint}) doesn't match #{current}"
          end
        end
      end

      exit_code
    end
  rescue Interrupt
  end
end
