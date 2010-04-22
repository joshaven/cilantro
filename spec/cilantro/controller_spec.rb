require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

begin
  require 'rack'
rescue LoadError
  require 'rubygems'
  require 'rack'
end


class TestController < Application
  namespace '/'
end

describe 'Cilantro::Controller' do
  it 'Module Namespacing' do
    defined?(Cilantro::Controller).should be_true
  end
  
  describe 'Application integration' do
    describe 'enviroment' do
      it 'should be linked through the application method' do
        TestController.application.should == Cilantro.app
      end

      it 'should process the before loop before rendering the request' do
        Object.send(:remove_const, :TestController)
        class TestController < Application
          namespace '/'

          before do
            @test_before =' World'
          end        

          get 'test' do
            'Hello' + @test_before.to_s
          end
        end

        response = mock_responce '/test', :get
        response.body.should eql("Hello World")
      end
    end
    
    describe 'helpers' do
      it 'should define application methods through :helper_method' do
        TestController.send(:helper_method, :caps) {|str| str.to_s.upcase}
        Cilantro.app.instance_methods.should include('caps')
      end
      
      it 'should define application methods through :helper' do
        TestController.send(:helper, :caps) {|str| str.to_s.upcase}
        Cilantro.app.instance_methods.should include('TestController_caps')
      end
    end
  
    describe 'error handeling' do
      it 'should allow a defination for error handeling: :error' do
        TestController.application.errors[500].should be_nil
        class TestController; error(500) {'500 error'}; end
        TestController.application.errors[500].should be_a_kind_of(Proc)
        TestController.application.errors[500].call.should eql('500 error')
      end
      
      it 'should have a shortcut for handeling not_found errors' do
        TestController.application.errors[404].should be_nil
        class TestController; not_found {'custom 404 error'}; end
        TestController.application.errors[404].should be_a_kind_of(Proc)
        TestController.application.errors[404].call.should eql('custom 404 error')
      end
      
      it 'should be able to have a custom error on a per controler basis' do
        class TestController < Application; error(500) {'500 error'}; end
        TestController.application.errors[500].call.should eql('500 error')
        class AnotherController < Application; error(500) {'Another 500 Error'}; end
        pending do
          TestController.application.errors[500].call.should eql('500 error')
          AnotherController.application.errors[500].call.should eql('Another 500 Error')
        end
      end
    end
  end
  
  describe 'route' do
    describe 'namespace' do
      before :each do
        Object.send(:remove_const, :TestController)
        class TestController < Application; namespace '/'; end
      end
  
      it 'should read and write as a string' do
        TestController.namespace 'sample'
        [TestController.namespace, TestController.scope, TestController.path].should == ['/sample','/sample','/sample']
      end
  
      it 'should read and write as a hash' do
        TestController.namespace({:sample => 'sample'})
        [TestController.namespace, TestController.scope, TestController.path].should == ['/sample','/sample','/sample']
      end
  
      it 'should read and write as a symbol' do
        TestController.namespace :sample
        [TestController.namespace, TestController.scope, TestController.path].should == ['/sample','/sample','/sample']
      end
  
      it 'should redefine the namespace not append it' do
        pending do
          TestController.namespace :sample
          TestController.namespace.should == '/sample'
          TestController.namespace :smile
          TestController.namespace.should == '/smile'
        end
      end
  
      it 'should raise an error when given an invalid object' do
        lambda {TestController.namespace ['/']}.should raise_error(ArgumentError)
      end
    end
    
    describe 'definitions' do
      before :all do
        Object.send(:remove_const, :TestController)
        class TestController < Application; namespace '/'; end
      end
      
      %w(get put post delete head).each do |verb|
        it "defines #{verb} routes" do
          TestController.send(verb, "test_#{verb}") { true }
          Cilantro.app.routes[verb.upcase].last.first.should == Regexp.new("^\/test_#{verb}$")
        end
      end
    end
  end
end
