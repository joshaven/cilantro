ENV['RACK_ENV'] = 'test'

require File.expand_path(File.join File.dirname(__FILE__), '..', 'lib', 'cilantro')
Cilantro.load_environment

dependency 'spec', :gem => 'rspec', :env => :test
dependency 'rack/test', :gem => 'rack-test', :env => :test


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
