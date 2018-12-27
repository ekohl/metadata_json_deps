require 'json'

module MetadataJsonDeps
  class Runner
    def initialize(filenames, verbose)
      @filenames = filenames
      @verbose = verbose
      @forge = MetadataJsonDeps::ForgeVersions.new
    end

    def run
      @filenames.each do |filename|
        puts "Checking #{filename}"
        checker = MetadataJsonDeps::MetadataChecker.new(JSON.parse(File.read(filename)), @forge)
        checker.dependencies.each do |dependency, constraint, current, satisfied|
          if satisfied
            if @verbose
              puts "  #{dependency} (#{constraint}) matches #{current}"
            end
          else
            puts "  #{dependency} (#{constraint}) doesn't match #{current}"
          end
        end
      end
    rescue Interrupt
    end

    def self.run(filenames, verbose = false)
      self.new(filenames, verbose).run
    end
  end
end
