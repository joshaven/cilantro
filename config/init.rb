# File: config/init.rb
# Sets up configurations and includes gems, libraries, controllers & models.
# To start the web server, use bin/cilantro.
# 
# To be loaded ONLY by Cilantro.load_environment. These things are already done at this point:
#   + ./lib is included in the ruby load path
#   + rubygems is loaded, but sandboxed to ./gems if ./gems exists
#   + if we're running in server or test mode, sinatra has been loaded


###################
# Section: Options
# Set your Cilantro options here.
require File.join 'lib', 'cilantro' unless defined? Cilantro
Cilantro.auto_reload = true


###################
# Section: Dependencies and Libraries
require CILANTRO_ROOT/'lib'/'cilantro'/'templater'
# dependency 'erubis'  # TODO: uncomment for faster erb (uses C bindings to do erb)

###################
# Section: Database Setup
dependency 'dm-core'
dependency 'dm-types'
dependency 'dm-migrations'
dependency 'dm-validations'

# Uncomment this to fire up a connection to the database using settings from config/database.yml config
# It's configured for DataMapper by default, you can set up your own connection routine here instead.
# Cilantro.setup_database
