require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'fileutils'

describe 'Cilantro' do
  describe 'Generator' do
    describe 'view generation' do
      before :all do
        @generator = Cilantro::Generator.new
        FileUtils.remove_dir APP_ROOT/'app' if File.exists? APP_ROOT/'app'
      end
      
      after :all do
        FileUtils.remove_dir APP_ROOT/'app'
      end
      
      it 'should not have a pre-existing file structure' do
        File.exists?(APP_ROOT/'app').should be_false
      end

      it 'should creaate the proper model' do
        @generator.create(:model, :test).should be_true
        # expected = "class Test\n  include DataMapper::Resource\n\n  property :id, Serial\n  property :data, String\n  property :created_at, DateTime\n  property :updated_at, DateTime\nend\n"
        expected = "class Test\n  include DataMapper::Resource\n\n  property :id, Serial\n  property :data, String\n  property :created_at, DateTime\n  property :updated_at, DateTime\n  \n  # TODO: The following line ensures that this model has a database table, this should be removed for production use\n  begin self.first rescue self.auto_migrate! end\nend\n" 
        get_file_as_string(APP_ROOT/'app'/'models'/'test.rb').should == expected
      end
      
      it 'should creaate the proper controller' do
        @generator.create(:controller, :test).should be_true
        expected = "class Tests < Application\n  namespace '/'\n\n  get :home do\n    view :index\n  end\n\n  # Main page\n  get 'new_index' do\n    view :index\n  end\n\n  # This is not yet limited to just one controller or namespace.\n  error do\n    Cilantro.report_error(env['sinatra.error'])\n    view :default_error_page\n  end\nend\n"
        get_file_as_string(APP_ROOT/'app'/'controllers'/'tests.rb').should == expected
      end
      
      it 'should creaate the proper view' do
        @generator.create(:view, :test).should be_true
        expected = "%h1 test\n%p hello world"
        get_file_as_string(APP_ROOT/'app'/'views'/'test'/'new.html.haml').should == expected
      end

    private
      def get_file_as_string(filename)
        data = ''
        f = File.open(filename, "r") 
        f.each_line do |line|
          data += line
        end
        return data
      end
    end
  end
end