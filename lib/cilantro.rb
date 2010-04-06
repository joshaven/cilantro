unless $LOADED_FEATURES.include?('lib/cilantro.rb') or $LOADED_FEATURES.include?('cilantro.rb')
  APP_ROOT = File.expand_path(File.join File.dirname(__FILE__), "..") unless defined?(APP_ROOT)

  IRB.conf[:PROMPT_MODE] = :SIMPLE if ::Object.const_defined?(:IRB)

  require File.expand_path(File.join APP_ROOT, 'lib', 'cilantro', 'base')
  require File.expand_path(File.join APP_ROOT, 'lib', 'cilantro', 'controller')
end
