ENV['RACK_ENV'] = 'test'

begin
  require 'rack'
rescue LoadError
  require 'rubygems'
  require 'rack'
end

require 'cilantro'
Cilantro.load_environment

dependency 'spec', :gem => 'rspec', :env => :test
dependency 'rack/test', :gem => 'rack-test', :env => :test
dependency 'sinatra/base'

# # moc_responce helper, uncomment to use
# # 
# # Example useage:
# #   response = mock_responce '/test', :get
# #   response.body.should eql("Hello World")
# def mock_responce(path, verb='GET', app=Cilantro.app)
#   request = Rack::MockRequest.env_for(path, 'HTTP_VERSION' => '1.1', 'REQUEST_METHOD' => verb.to_s.upcase)
#   Rack::MockResponse.new *Rack::Chunked.new(app).call(request)
# end
