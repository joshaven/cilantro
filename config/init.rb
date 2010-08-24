# This is where the app should be launched from.  

require 'rubygems'
require 'lib/cilantro'

require 'environment'

# TODO: default loading the load_environment from a yaml file...
Cilantro.load_environment(
  :environment  => :production,
  :views        => APP_ROOT/'app'/'views',
  :controllers  => APP_ROOT/'app'/'controllers',
  :models       => APP_ROOT/'app'/'models',
  :lib          => APP_ROOT/'lib'
)


