#!/usr/bin/env ruby

require 'json'
require 'puppet_forge'
require 'semantic_puppet'

class ForgeVersions
  def initialize
    @cache = {}
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

class MetadataChecker
  def initialize(filename, forge)
    @filename = filename
    @forge = forge
  end

  def metadata
    @metadata ||= JSON.parse(File.read(@filename))
  end

  def module_dependencies
    metadata['dependencies'].map do |dep|
      [dep['name'], SemanticPuppet::VersionRange.parse(dep['version_requirement'])]
    end
  end

  def dependencies
    module_dependencies.map do |dependency, constraint|
      [dependency, constraint, @forge.get_current_version(dependency)]
    end
  end
end

forge = ForgeVersions.new
verbose = false

ARGV.each do |filename|
  puts "Checking #{filename}"
  checker = MetadataChecker.new(filename, forge)
  checker.dependencies.each do |dependency, constraint, current|
    if constraint.include?(current)
      if verbose
        puts "  #{dependency} (#{constraint}) matches #{current}"
      end
    else
      puts "  #{dependency} (#{constraint}) doesn't match #{current}"
    end
  end
end
