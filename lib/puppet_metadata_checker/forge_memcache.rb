require 'dalli'

module PuppetMetadataChecker
  class ForgeMemcache
    def initialize(server='localhost:11211', ttl=3600)
      @cache = Dalli::Client.new(server, { :expires_in => 3600 })
    end

    def [](key)
      return @cache.get(key)
    end

    def []=(key, value)
      return @cache.set(key, value)
    end
  end
end
