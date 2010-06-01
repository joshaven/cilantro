require File.join(CILANTRO_ROOT, 'lib', 'cilantro', 'dependencies')

dependency 'rack'
dependency 'thin'
dependency 'eventmachine'
dependency 'daemons'
dependency 'sinatra/base', :gem => 'sinatra'
Sinatra.send(:remove_const, :Templates)
class Application < Sinatra::Base
  include Cilantro::Application
  include Cilantro::Templater if defined? Cilantro::Templater
  enable :sessions
end
