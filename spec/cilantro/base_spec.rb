require File.expand_path File.join(File.dirname(__FILE__),'..','spec_helper')
require 'fileutils'


describe 'Cilantro' do
  describe 'environment' do
    it 'should get & set env' do
      Cilantro.env.should eql('test')
      Cilantro.env(:spec).should eql('spec')
      Cilantro.env.should eql('spec')
      Cilantro.env(:test).should eql('test') # just being nice and resetting the environment
    end

    it 'should be linked to the Sinatra ::Application' do
      Cilantro.app.should == ::Application
    end

    describe 'config' do
      it 'should should have loaded the config' do
        Cilantro.instance_variable_get('@config_loaded').should be_true
      end
    
      it 'should load the environment config' do
        Cilantro.config.should == {}
        cfg_file = "#{CILANTRO_ROOT}/config/#{Cilantro.env}.yml"
        File.open(cfg_file, 'w') {|f| f.write "--- \n:test: true\n" }
        Cilantro.instance_variable_set('@config', nil)
        Cilantro.config.should == {:test => true}
        File.delete cfg_file
      end
      
      it 'should have default server_options' do
        Cilantro.server_options.should == {
          :environment=>'test', 
          :static=>true, 
          :public=>'public', 
          :server=>'thin', 
          :logging=>true, 
          :raise_errors=>false, 
          :show_exceptions=>true
        }        
      end
    end

    describe 'paths' do
      it 'should load the lib folder into the gem path' do
        $:.should include(CILANTRO_ROOT/'/lib')
      end

      it 'should know the paths' do
        # log_path & pid_path
        if File.exist?(CILANTRO_ROOT/'log') && File.writable?(CILANTRO_ROOT/'log')
          Cilantro.log_path.should == CILANTRO_ROOT/'log'
          Cilantro.pid_path.should == CILANTRO_ROOT/'log'
        elsif File.exist?(CILANTRO_ROOT/'config') && File.writable?(CILANTRO_ROOT/'config')
          Cilantro.log_path.should == CILANTRO_ROOT/'config'
          Cilantro.pid_path.should == CILANTRO_ROOT/'config'
        else
          Cilantro.log_path.should == Dir.pwd
          Cilantro.pid_path.should == Dir.pwd
        end
      end
    end
    
    describe 'prequisites required' do
      it 'should have already required cilantro/dependencies' do
        require(CILANTRO_ROOT/'lib'/'cilantro'/'dependencies').should be_false
      end
    
      it 'should load all lib, model & controller files when Cilantro.load_environment is called' do
        FileUtils.mkdir_p CILANTRO_ROOT/'app'/'models'
        FileUtils.mkdir_p CILANTRO_ROOT/'app'/'controllers'
        File.open(CILANTRO_ROOT/'app'/'models'/'widget.rb', 'w') {|f| f.write "class Widget;end" }
        File.open(CILANTRO_ROOT/'app'/'controllers'/'widgets.rb', 'w') {|f| f.write "class Widgets;end" }

        Cilantro.load_environment
      
        Dir.glob('lib'/'*.rb').size.should > 0
        Dir.glob('lib'/'*.rb').each {|f| require(f.split(/\//).last).should be_false }
              
        Dir.glob(CILANTRO_ROOT/'app'/'models'/'*.rb').size.should > 0
        Dir.glob(CILANTRO_ROOT/'app'/'models'/'*.rb').each {|f| require(f).should be_false }
    
        Dir.glob(CILANTRO_ROOT/'app'/'controllers'/'*.rb').size.should > 0
        Dir.glob(CILANTRO_ROOT/'app'/'controllers'/'*.rb').each {|f| require(f).should be_false}
        
        FileUtils.rm_r CILANTRO_ROOT/'app'
      end
    end

    describe 'database' do
      it 'should load the database_config' do
        dependency 'sqlite3', :gem => 'sqlite3-ruby', :env => [:development, :test]
        dependency 'do_sqlite3'
        dependency 'dm-core'
        dependency 'data_objects'
        # bypass the reading of the config file through yml file by setting the variable directly
        Cilantro.instance_variable_set '@database_config', {:adapter=>'sqlite3', :database=>':memory:'}
        Cilantro.database_config.should == {:adapter=>'sqlite3', :database=>':memory:'}
        Cilantro.setup_database.should be_true
        class User
          include DataMapper::Resource
          property :id, Serial
          property :name, String
          self.auto_migrate!
        end
        
        User.new(:name => 'Joe User').save.should be_true
        User.first.name.should == 'Joe User'
      end
    end
  end
  
  describe 'auto-reloading' do
    it 'should not allow auto-reloading unless the master process is cilantro' do
      Cilantro.instance_variable_set('@auto_reload', true).should be_true
      Cilantro.auto_reload.should be_false
    end
    
    it 'should allow auto-reload when the master process is cilantro' do
      Cilantro.instance_variable_set('@auto_reload', true)
      process_name = $0; $0 = 'cilantro' # fake out the process name
      Cilantro.auto_reload.should be_true
      $0 = process_name # restore the process name
    end
  end

  describe 'TCP Server' do
    after :each do
      if @pid.is_a? Fixnum
        Process.kill("SIGINT", @pid)
        Process.wait
      end
    end
    
    it "should listen on tcp, if this fails it may be due to port 5000 being in use at the onset of the test." do
      port_in_use?(5000).should be_false
      @pid = fork do
        server = Rack::Handler.get('thin')
        server.run Cilantro.app, :Host => '0.0.0.0', :Port => 5000
        exit # otherwise this fork will continue from where it was forked
      end
      sleep 0.1
      port_in_use?(5000).should be_true
    end
  end

  describe 'error reporting' do
    it 'should notify' do
      # Cilantro.config[:notify] = 'somethin@gmail.com'
      # Cilantro.config[:username] = 'something@gmail.com'
      # Cilantro.config[:password] = 'password'
      # 
      # Cilantro.config[:notify].should == 'yourtech@gmail.com'
      pending do
        Cilantro.report_error(Exception.new 'Hello world').should be_true
      end
    end
  end
end
