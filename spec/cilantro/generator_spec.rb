require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')
require 'fileutils'

describe 'Cilantro' do
  describe 'Generator' do
    describe 'view generation' do
      before :all do
        @generator = Cilantro::Generator.new
        FileUtils.remove_dir File.join(APP_ROOT, 'app') if File.exists? File.join(APP_ROOT, 'app')
      end
      
      after :all do
        FileUtils.remove_dir File.join(APP_ROOT, 'app')
      end
      
      it 'should not have a pre-existing file structure' do
        File.exists?(File.join(APP_ROOT, 'app')).should be_false
      end
      
      it 'should create the view' do
        @generator.create(:view, :test).should be_true
        File.exists?(File.join(APP_ROOT, 'app', 'views', 'test', 'new.haml')).should be_true
      end
      
      it 'should creaate the proper model' do
        
# TODO: Move the text for the model, view, etc. to external files
        
        @generator.create(:model, :test).should be_true
        
        expected = "class Test\n  include DataMapper::Resource\n\n  property :id, Serial\n  property :data, String\n  property :created_at, DateTime\n  property :updated_at, DateTime\nend"

        get_file_as_string(File.join(APP_ROOT, 'app', 'models', 'test.rb')).should == expected
      end
      
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