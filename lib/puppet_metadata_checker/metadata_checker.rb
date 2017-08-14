require 'semantic_puppet'

module PuppetMetadataChecker
  class MetadataChecker
    def initialize(metadata, forge)
      @metadata = metadata
      @forge = forge
    end

    def module_dependencies
      return [] unless @metadata['dependencies']

      @metadata['dependencies'].map do |dep|
        constraint = dep['version_requirement'] || '>= 0'
        [dep['name'], SemanticPuppet::VersionRange.parse(constraint)]
      end
    end

    def dependencies
      module_dependencies.map do |dependency, constraint|
        current = @forge.get_current_version(dependency)
        [dependency, constraint, current, constraint.include?(current)]
      end
    end
  end
end
