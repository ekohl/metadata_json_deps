require 'puppet_metadata'

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
        metadata = PuppetMetadata.read(filename)

        metadata.dependencies.map do |dependency, constraint|
          current = @forge.get_current_version(dependency)

          if constraint.include?(current)
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
