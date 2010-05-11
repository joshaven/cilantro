require 'rubygems'
require 'rake'

# require 'fileutils' # TODO: is this necessary?

#######################################
# Load Jeweler: gem creation/management
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "cilantro"
    gem.summary = %Q{A Web Framework based on Sinatra}
    gem.description = %Q{A framework build on top of Sinatra, boasting automagic gem management, auto-reloading in development, and an innovative way to manage templates.}
    gem.email = "yourtech@gmail.com"
    gem.homepage = "http://github.com/joshaven/cilantro"
    gem.authors = ["Joshaven Potter"]
    gem.add_dependency "rack", ">= 1.0"
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency 'dm-core',     '~> 0.10.2' 
    gem.add_development_dependency 'do_sqlite3',  '~> 0.10.1.1'
    # gem.add_development_dependency 'yard',        '~> 0.5.4' # Needed for RDoc
    
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end


###########################
# Load Cilantro Environment

# Really need some way to determine what the ENV['RACK_ENV'] is "supposed" to be ..
# or should it be set globally so we know our context?
ENV['RACK_ENV'] = 'rake'

task :load_cilantro do
  if File.exists?('lib/cilantro.rb')
    require 'lib/cilantro'
  else
    raise "lib/cilantro.rb is missing!"
  end
end

namespace :env do
  task(:rake => [:load_cilantro]) { Cilantro.load_environment(:rake) }
  task(:development => [:load_cilantro]) { Cilantro.load_environment(:development) }
  task(:production => [:load_cilantro]) { Cilantro.load_environment(:production) }
end

task :production_db => [:load_cilantro] do
  Cilantro.database_config 'config/database.production.yml' if File.exists?('config/database.production.yml')
end

# Load any app level custom rakefile extensions from lib/tasks
tasks_path = File.join(File.dirname(__FILE__), "tasks")
rake_files = Dir["#{tasks_path}/*.rake"]
rake_files.each do |rake_file|
  begin
    load rake_file
  rescue LoadError
    warn "Could not load #{rake_file}"
  end
end

##############################################################################
# ADD YOUR CUSTOM TASKS IN /tasks
# NAME YOUR RAKE FILES file_name.rake
##############################################################################
