Gem::Specification.new do |s|
  s.name        = 'puppet_metadata_checker'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = 'Check your Puppet metadata'
  s.description = 'Verify all your dependencies allow the latest versions on Puppet Forge'
  s.authors     = ['Ewoud Kohl van Wijngaarden']
  s.email       = 'ewoud+rubygems@kohlvanwijngaarden.nl'
  s.files       = Dir['lib/**/*.rb'] + Dir['bin/*']
  s.homepage    = 'https://github.com/ekohl/puppet_metadata_checker'
  s.metadata    = { 'source_code_uri' => 'https://github.com/ekohl/puppet_metadata_checker' }
  s.executables << 'check-metadata'

  s.required_ruby_version = Gem::Requirement.new('>= 2.0.0')

  s.add_runtime_dependency 'puppet_forge', '~> 2.2'
  s.add_runtime_dependency 'semantic_puppet', '~> 1.0'
end
