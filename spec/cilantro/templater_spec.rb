require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'fileutils'

describe :Cilantro do
  before :all do
    class StubApp
      include Cilantro::Application
      include Cilantro::Controller
      include Cilantro::Templater
    end

    @app = StubApp.new
    @app.namespace '/'
  end
  
  describe :Template do
    it 'should have some specs that describe :Template'
  end

  describe :Layout do
    before :all do
      @name = 'test_berry_layout'
      @ext = 'haml'
      @layout_dir = File.join(APP_ROOT, 'app', 'views', 'layouts')
      @layout_content = "<p>Hello World</p>"
      # @layout_helper_content = %q{module Cilantro; def self.smashing_good_time;true;end;end}
      @layout_helper_content = %q{def smashing_good_time();true;end}
      @layout_path = File.join @layout_dir, "#{@name}.#{@ext}"
      @layout_helper_path = File.join @layout_dir, "#{@name}"

      # make directory & file as needed
      FileUtils.mkdir_p @layout_dir
      File.open(@layout_path, 'w') {|f| f.write(@layout_content) }
      File.open(@layout_helper_path, 'w') {|f| f.write(@layout_helper_content) }
    end
    
    after :all do
      FileUtils.remove_dir File.join(APP_ROOT, 'app')
    end
    
    it 'should read layout from the proper directory' do
      Cilantro::Layout.get_layout(@name).should == [@layout_path, @layout_content]
    end

    describe :initialization do
      # def initialize(controller, name, namespace='/')
      #   @controller = controller
      #   @name = name
      #   @locals = {}
      #   @namespace = namespace
      #   # load view helper if present
      #   if layout_helper = Layout.get_layout(@name, 'rb')
      #     @html = :helper
      #     instance_eval(layout_helper.last)
      #     @html = :rendering
      #   end
      #   @layout = Layout.get_layout(@name)
      # end
      # pending {fail}
      before :all do
        class TestController < Application; namespace '/'; end
      end
      it 'should initialize' do
        Cilantro::Layout.new(TestController, 'standard').should be_a(Cilantro::Layout)
      end
      
      it 'should set instance_variables' do
        l=Cilantro::Layout.new(TestController, @name, '/test')
        l.instance_variable_get('@controller').should == TestController
        l.instance_variable_get('@name').should == @name
        l.instance_variable_get('@locals').should == {}
        l.instance_variable_get('@namespace').should == '/test'
      end
      
      it 'should load helpers' do
        l=Cilantro::Layout.new(TestController, @name, '/')
        # l.methods.should include('greet_helper')
        File.exists?(@layout_helper_path).should be_true
        # Cilantro.methods.should include('smashing_good_time')
# The helper file is opened but it doesn't seem to be executed because syntax errors don't cause issues
# It is in an instance eval in a Cilantro::Layout instance 'l'
# It probably is run on :render!
        pending {fail}
      end
      
      
    end

    it 'should render!' do
      # def render!(content_for_layout)
      #   if @layout
      #     render(@layout, self, locals.merge(:content_for_layout => content_for_layout))
      #   else
      #     content_for_layout
      #   end
      # end
      pending {fail}
    end
  end

  describe :FormatResponder do
    # before :all do
    #   @fr = Cilantro::FormatResponder.new
    # end
    # it 'should :format_proc=' do
    #   fr.format_proc=(lambda {"hello world"}).should be_a(Proc)
    # end
    it 'should be removed from the code because it is only used by the :respond_to method which is broken anyway'
  end

  describe 'Templater (module)' do
    describe 'Cilantro Integration' do
      it 'should be included in Appliation' do
        Cilantro.app.instance_methods.should include('layout')
      end
    end

    describe :layout do
      it 'included in Applicaion should receive :layout and set @layout_name' do
        @app.layout('testme').should == 'testme'
        @app.instance_variable_get('@layout_name').should eql('testme')
      end
  
      it 'should fix @layout_name as a string even' do
        pending do
          @app.layout(:testme).should == 'testme'
          @app.instance_variable_get('@layout_name').should eql('testme')
        end
      end
    end

    describe :view do
      it 'return a Cilantro::Template' do
        @app.should respond_to('view')
        @app.view().should be_a(Cilantro::Template)
      end
    
      it 'should be able to pass locals when the view whither named or not'
    
      it 'should set view name' do
        @app.view('view_name').name.should == 'view_name'
      end
    
      it 'should receive a block' do
        t = @app.view('view_name') do |v| 
          v.is_a?(Cilantro::Template) ? 'Hello World!' : 'What the hay?' 
        end
        t.should be_a(Cilantro::Template)
      end
    end
  
    describe :respond_to do
      it 'Cilantro::Templater::respond_to should be removed' do
        # It seems that this method is broken because it references 'accepts' which has been removed from the active code
        pending do
          @app.respond_to?('respond_to').should be_false
        end
      end
    end
  end
end