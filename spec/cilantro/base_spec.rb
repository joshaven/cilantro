require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Cilantro' do
  describe 'environment' do
    it 'should get & set env' do
      Cilantro.env.should eql(:test)
      Cilantro.env(:spec).should eql(:spec)
      Cilantro.env.should eql(:spec)
      Cilantro.env(:test).should eql(:test) # just being nice and resetting the environment
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
        cfg_file = "#{APP_ROOT}/config/#{Cilantro.env}.yml"
        File.open(cfg_file, 'w') {|f| f.write "--- \n:test: true\n" }
        Cilantro.instance_variable_set('@config', nil)
        Cilantro.config.should == {:test => true}
        File.delete cfg_file
      end
      
      it 'should have default server_options' do
        Cilantro.server_options.should == {
          :environment=>:test, 
          :static=>true, 
          :public=>"public", 
          :server=>"thin", 
          :logging=>true, 
          :raise_errors=>false, 
          :show_exceptions=>true
        }
      end
    end

    describe 'paths' do
      it 'should load the lib folder into the gem path' do
        $:.should include(File.join APP_ROOT, '/lib')
      end

      it 'should know the paths' do
        # log_path & pid_path
        if File.exist?(File.join(APP_ROOT, 'log')) && File.writable?(File.join(APP_ROOT, 'log'))
          Cilantro.log_path.should == File.join(APP_ROOT, 'log')
          Cilantro.pid_path.should == File.join(APP_ROOT, 'log')
        elsif File.exist?(File.join(APP_ROOT, 'config')) && File.writable?(File.join(APP_ROOT, 'config'))
          Cilantro.log_path.should == File.join(APP_ROOT, 'config')
          Cilantro.pid_path.should == File.join(APP_ROOT, 'config')
        else
          Cilantro.log_path.should == File.join(Dir.pwd)
          Cilantro.pid_path.should == File.join(Dir.pwd)
        end
      end
    end
    
    describe 'prequisites required' do
      it 'should have already required cilantro/dependencies' do
        require('cilantro/dependencies').should be_false
      end
    
      it 'should have already loaded all lib, model & controller files' do
        Dir.glob("lib/*.rb").each {|f| require(f.split(/\//).last).should be_false }
        Dir.glob("app/models/*.rb").each {|f| require(f).should be_false }
        Dir.glob("app/controllers/*.rb").each {|f| require(f).should be_false}
      end
    end

    describe 'database' do
      it 'should load the database_config' do
        Cilantro.database_config.should == nil
        pending do
          # test by making a database config
          fail
        end
      end

      it 'should load the database'
    end
  end
  
  describe 'auto-reloading' do
    it 'should not allow auto-reloading unless the master process is cilantro' do
      Cilantro.auto_reload = true
      Cilantro.instance_variable_get('@auto_reload').should be_true
      Cilantro.auto_reload.should be_false
    end
    
    it 'should allow auto-reload when the master process is cilantro'
    
    it 'should know when something has changed' do
      Cilantro.instance_variable_get('@something_changed').should be_false 
      pending do
        #change something
        Cilantro.instance_variable_get('@something_changed').should be_true
      end
    end
  end

  describe 'TCP Server' do
    after :each do
      if @pid.is_a? Fixnum
        Process.kill("SIGINT", @pid)
        Process.wait
      end
    end
    
    it "should listen on tcp" do
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
