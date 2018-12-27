require 'puppet_forge'
require 'semantic_puppet'

module MetadataJsonDeps
  class ForgeVersions
    def initialize(cache = {})
      @cache = cache
    end

    def get_current_version(name)
      name = name.sub('/', '-')
      version = @cache[name]

      unless version
        @cache[name] = version = get_version(get_mod(name))
      end

      version
    end

    private

    def get_mod(name)
      PuppetForge::Module.find(name)
    end

    def get_version(mod)
      SemanticPuppet::Version.parse(mod.current_release.version)
    end
  end
end
