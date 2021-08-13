begin
  require 'rspec/core/rake_task'
rescue LoadError
else
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
end
