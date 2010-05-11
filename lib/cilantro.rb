# TODO: the following line may mess with the sandboxed gems environment
require 'rubygems'

unless $LOADED_FEATURES.include?('lib/cilantro.rb') or $LOADED_FEATURES.include?('cilantro.rb')
  # APP_ROOT = File.expand_path(File.join File.dirname(__FILE__), "..") unless defined?(APP_ROOT)
  APP_ROOT = Dir.pwd unless defined?(APP_ROOT)
  CILANTRO_ROOT = File.expand_path(File.join File.dirname(__FILE__), "..") unless defined?(CILANTRO_ROOT)

  IRB.conf[:PROMPT_MODE] = :SIMPLE if ::Object.const_defined?(:IRB)

  require 'rack'
  require 'extlib'

  require File.expand_path(File.join CILANTRO_ROOT, 'lib', 'cilantro', 'base')
  require File.expand_path(File.join CILANTRO_ROOT, 'lib', 'cilantro', 'controller')
  require File.expand_path(File.join CILANTRO_ROOT, 'lib', 'cilantro', 'templater')
  require File.expand_path(File.join CILANTRO_ROOT, 'lib', 'cilantro', 'auto_reload')
  #
  require File.expand_path(File.join CILANTRO_ROOT, 'lib', 'cilantro', 'generator')
end
