begin 
  require 'extlib'
rescue LoadError
  require 'rubygems'
  retry
end

APP_ROOT = Dir.pwd unless defined?(APP_ROOT)
CILANTRO_ROOT = File.expand_path(File.dirname(__FILE__)/"..") unless defined?(CILANTRO_ROOT)

unless $LOADED_FEATURES.include?(CILANTRO_ROOT/'lib'/'cilantro.rb') or $LOADED_FEATURES.include?('lib/cilantro.rb') or $LOADED_FEATURES.include?('cilantro.rb')
  IRB.conf[:PROMPT_MODE] = :SIMPLE if ::Object.const_defined?(:IRB)
  
  # load the core of Cilantro
  require CILANTRO_ROOT/'lib'/'cilantro'/'base'
  
  # sandbox gems & setup dependency command...
  require CILANTRO_ROOT/'lib'/'cilantro'/'dependencies'
  
  # Define controller and templater
  require CILANTRO_ROOT/'lib'/'cilantro'/'controller'
  require CILANTRO_ROOT/'lib'/'cilantro'/'templater'
  require CILANTRO_ROOT/'lib'/'cilantro'/'helpers'
  
  # Permit auto reloading of source files
  dependency 'rack'
  require File.expand_path(CILANTRO_ROOT/'lib'/'cilantro'/'auto_reload')
  
  # Dynamic application creation...
  dependency 'extlib'
  require File.expand_path(CILANTRO_ROOT/'lib'/'cilantro'/'generator')
end
