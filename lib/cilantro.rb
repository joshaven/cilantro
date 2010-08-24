require 'extlib'
require 'sinatra'

# CILANTRO_ROOT is the same as APP_ROOT if Cilantro is in your app's lib otherwise it is the path inside the gem
APP_ROOT = Dir.pwd unless defined?(APP_ROOT)
CILANTRO_ROOT = File.expand_path(File.dirname(__FILE__)/"..") unless defined?(CILANTRO_ROOT)

Dir.glob(CILANTRO_ROOT/'lib'/'cilantro'/'*.rb') {|cilantro_file| require cilantro_file}
   