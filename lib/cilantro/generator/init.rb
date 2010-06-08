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
require CILANTRO_ROOT/'lib'/'cilantro'/'templater'
# dependency 'erubis'  # TODO: uncomment for faster erb (uses C bindings to do erb)


###################
# Section: Database Setup
dependency 'dm-core'
dependency 'dm-sqlite-adapter', :env => :development
# dependency 'do_mysql', :env => :production  # uncomment & edit your config/database.yml for mysql
dependency 'dm-migrations'
dependency 'dm-types'
dependency 'dm-validations'
dependency 'dm-timestamps'

# The following will load the Cilantro app
Cilantro.load_environment :irb if Cilantro.env.nil?
