ENV['RACK_ENV'] = 'test'

begin
  require 'rack'
  require 'extlib'
rescue LoadError
  require 'rubygems'
  require 'rack'
  require 'extlib'
end

APP_ROOT = File.expand_path( File.dirname(__FILE__)/'..' )

require File.expand_path(File.join File.dirname(__FILE__), '..', 'lib', 'cilantro') unless defined?(Cilantro)
Cilantro.load_environment

dependency 'spec', :gem => 'rspec', :env => :test
dependency 'rack/test', :gem => 'rack-test', :env => :test
dependency 'sinatra/base'

# spec helper methods
require 'socket'
def port_in_use?(port)
  begin
    s = TCPSocket.new('0.0.0.0', port.to_s)
    s.close
    return true
  rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
    return false
  end
end  

# Example useage:
#   response = mock_responce '/test', :get
#   response.body.should eql("Hello World")
def mock_responce(path, verb='GET', app=Cilantro.app)
  request = Rack::MockRequest.env_for(path, 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => verb.to_s.upcase)
  Rack::MockResponse.new *Rack::Chunked.new(app).call(request)
end