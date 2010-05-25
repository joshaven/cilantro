# File: config/init.rb
# Sets up configurations and includes gems, libraries, controllers & models.
# To start the web server, use bin/cilantro.
# 
# To be loaded ONLY by Cilantro.load_environment. These things are already done at this point:
#   + ./lib is included in the ruby load path
#   + rubygems is loaded, but sandboxed to ./gems if ./gems exists
#   + if we're running in server or test mode, sinatra has been loaded

###################
# Section: required setup
require 'rubygems'
require 'cilantro'


###################
# Section: Options
# Set your Cilantro options here.
Cilantro.auto_reload = true


###################
# Section: Dependencies and Libraries
require File.join CILANTRO_ROOT, 'lib', 'cilantro', 'templater'
# dependency 'erubis'  # TODO: uncomment for faster erb (uses C bindings to do erb)


###################
# Section: Database Setup
dependency 'sqlite3', :gem => 'sqlite3-ruby', :env => :development
dependency 'do_sqlite3', :env => :development
# dependency 'do_mysql', :env => :production  # uncomment & edit your config/database.yml for mysql
dependency 'dm-core'
dependency 'data_objects'
dependency 'dm-migrations'
#dependency 'dm-types'        # uncomment for more datamapper types
#dependency 'dm-validations'  # uncomment for datamapper validations



# Uncomment this to fire up a connection to the database using settings from config/database.yml config
# It's configured for DataMapper by default, you can set up your own connection routine here instead.
Cilantro.setup_database
Cilantro.load_environment :irb unless ENV['RACK_ENV']
