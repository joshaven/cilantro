require CILANTRO_ROOT/'lib'/'cilantro'/'system'/'mysql_fix' if File.exists?(CILANTRO_ROOT/'lib'/'cilantro'/'system'/'mysql_fix')

module Cilantro
  class << self
    def env(e=nil)
      e ? ENV['RACK_ENV']=e.to_s : ENV['RACK_ENV']||='development'
    end

    attr_writer :auto_reload
    def auto_reload
      # auto_reload only works when Cilantro is the master process
      $0 =~ /(^|\/)cilantro$/ && @auto_reload
    end

    def load_config(env=nil)
      # override env with given env and set local env variable
      env ||= self.env(env)

      # Setup the path unless already done
      # TODO: Dry this... it is done in so many places...
      $: << APP_ROOT unless $:.include?(APP_ROOT)
      $: << APP_ROOT/'lib' unless $:.include?(APP_ROOT/'lib')

      # Prepare our dependency-loading environment
      require CILANTRO_ROOT/'lib'/'cilantro'/'dependencies'

      # Beginning with env, we determine which pieces of the app's environment need to be loaded.
      # If in development or production mode, we need to load up Sinatra:
      # puts @something_changed ? "Reloading the app..." : "Loading Cilantro environment #{env.inspect}" unless env == :test
      puts @reloader.app_updated? ? "Changes detected, Reloading the app..." : "Loading Cilantro environment #{env.inspect}" if @reloader.is_a?(Cilantro::AutoReloader) && env != 'test'
      if ['development', 'test', 'production'].include?(env)
        # define the Application class which inherits from Sinatra::Base
        require CILANTRO_ROOT/'lib'/'cilantro'/'sinatra'
        set_options(
          :static => true,
          :public => 'public',
          :server => (auto_reload ? 'thin_cilantro_proxy' : 'thin'),
          :logging => true,
          :raise_errors => (env == 'production'),
          :show_exceptions => !(env == 'production'),
          :environment => env
        )
      end
      # ****
      @config_loaded = true
    end

    # Entry point after Cilantro has been required... This will load the proper cilantro environment
    def load_environment(env=nil)
      env ||= self.env(env)
      # env(specified_env)
      load_config(env) unless @config_loaded

      # Load the app pre-environment. This reloads with auto-reloading.
      load APP_ROOT/'config'/'init.rb'

      # If config/init sets auto-reload, then don't load the rest of the app - save that for the auto-spawned processes.
      return false if auto_reload && require(CILANTRO_ROOT/'lib'/'cilantro'/'auto_reload')

      # Lastly, we'll load the app files themselves: lib, models, then controllers
        # lib/*.rb - those already loaded won't be reloaded.
        Dir.glob("lib/*.rb").each {|file| require file.split(/\//).last }
        # app/models/*.rb
        setup_database # ensure that DataMapper is connected to the database
        Dir.glob("app/models/*.rb").each {|file| require file}
        # app/controllers/*.rb UNLESS in irb
        Dir.glob("app/controllers/*.rb").each {|file| require file} if [:development, :production, :test].include?(env)

      return true
    end

    def config_path
      APP_ROOT + '/config'
    end
    def log_path
      [APP_ROOT+'/log', APP_ROOT+'/config', Dir.pwd].each do |p|
        break p if File.directory?(p) && File.writable?(p)
      end || nil
    end
    def pid_path
      log_path
    end

    attr_reader :server_options
    def set_options(options)
      @server_options ||= {}
      @server_options.merge!(options)
      ::Application.set @server_options
    end

    def app
      if auto_reload # if auto-reload, the "app" is the auto-reloader
        @reloader ||= Cilantro::AutoReloader.new
      else # otherwise, we're either NOT auto-reloading, or we're "inside" the auto-reloader
        ::Application
      end
    end

    def config
      @config ||= File.exists?("#{APP_ROOT}/config/#{env}.yml") ? YAML.load_file("#{APP_ROOT}/config/#{env}.yml") : {}
    end

    def database_config(file=nil)
      @database_config ||= begin
        if file
          @database_config_file = file
        else
          cfg = nil
          [@database_config_file, config[:database_config], "#{APP_ROOT}/config/database.#{env}.yml", "#{APP_ROOT}/config/database.yml"].compact.any? do |config_file|
            if File.exists?(config_file)
              @database_config_file = config_file
              cfg = (YAML.load_file(@database_config_file) || {}) rescue {}
              cfg = (cfg[env] || cfg[env.to_s]) if (cfg[env] || cfg[env.to_s]).is_a?(Hash)
              cfg = (cfg[:database] || cfg['database']) if (cfg[:database] || cfg['database']).is_a?(Hash)
              cfg
            else # no database config... loading in RAM
              false
            end
          end
          
          ## permit use without a database by nominating an in-memory-database
          unless cfg
            warn  "from: Cilantro.database_config: No Database specified, nominating a non-persistent RAM based database.  " +
                  "Please specify a database by creating #{APP_ROOT}/config/database.yml"
            cfg = 'sqlite3::memory:'
          end

          cfg
        end
      end
    end

    def setup_database
      DataMapper.setup(:default, ENV['DATABASE_URL'] || Cilantro.database_config)
    end

    def report_error(error)
      # Make the magic happen!
      # (jabber me when there's an error loading an app)
      begin
        if config[:notify]
          warn "\nNotifying #{config[:notify]} of the error."
          dependency 'xmpp4r'
          client = Jabber::Client.new(Jabber::JID.new("#{config[:username]}/cilantro"))
          client.connect('talk.google.com', '5222')
          client.auth(config[:password])
          client.send(Jabber::Presence.new.set_type(:available))
          msg = Jabber::Message.new(config[:notify], "#{error.inspect}\n#{error.backtrace.join("\n")}")
          msg.type = :chat
          client.send(msg)
          client.close
        else
          warn "\n! Nobody configured to notify via jabber."
        end
      rescue
        warn "Could not notify admin via jabber"
      end
    end

    # Example usage:
    #   def method_name(args)
    #     Cilantro::deprecate("Cilantro#method_name","Cilantro#new_method_name")
    #     ... do what ever it did
    #   end
    def deprecate(method, alternate_method=nil)
      message = "\n" +
        "*****************************************************************\n" +
        "DEPRECATION WARNING: you are using deprecated behaviour that will\n" +
        "be removed from a future version of Cilantro.\n" +
        "\n" +
        "#{caller(0)[2]}\n" +
        "\n" +
        "* #{method} is deprecated.\n"
      
      message << "\n* please use #{alternate_method} instead.\n" if alternate_method

      message << "*****************************************************************"
      warn(message)
    end
  end

  ########################################################################
  # Module: Cilantro::Application
  # Sets up the behavior of a Cilantro application.
  # Mainly this is included into ::Application < Sinatra::Base in sinatra.rb
  module Application
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        def method_missing(method_name, *args)
          # Try the helper methods for the current controller.
          send(controller.name.to_s + '_' + method_name.to_s, *args) rescue super
        end
      end
    end

    # Generates a url from routes.
    # Pass a hash of values (or an object that responds to the respective methods)
    # for named url values, or pass them in order as simple arguments.
    # Regexp routes will work too, as long as you pass in arguments for all
    # non-named parenthesis sections as well, and there are no other regexp special
    # characters present.
    def url(name, *args)
      options = args.last.is_a?(String) || args.last.is_a?(Numeric) ? nil : args.pop
      match, needs = self.class.route_names[name.to_sym]
      raise RuntimeError, "Can't seem to find named route #{name.inspect}!", caller if match.nil? && needs.nil?
      needs = needs.dup
      match = match.source.sub(/^\^/,'').sub(/\$$/,'')
      while match.gsub!(/\([^()]+\)/) { |m|
          # puts "M: #{m}"
          if m == '([^/?&#]+)'
            key = needs.shift
            # puts "Needs: #{key}"
            if options.is_a?(Hash)
              # puts "Hash value"
              options[key.to_sym] || options[key.to_s] || args.shift
            else
              if options.respond_to?(key)
                # puts "Getting value from object"
                options.send(key)
              else
                # puts "Shifting value"
                args.shift
              end
            end
          elsif m =~ /^\(\?[^\:]*\:(.*)\)$/
            # puts "matched #{m}"
            m.match(/^\(\?[^\:]*\:(.*)\)$/)[1]
          else
            raise "Could not generate route :#{name} for #{options.inspect}: need #{args.join(', ')}." if args.empty?
            args.shift
          end
        }
      end
      match.gsub(/\\(.)/,'\\1') # unescapes escaped characters
    end

    def namespace
      (0..caller.length).each do |i|
        next unless caller[i] =~ /[A-Z]+ /
        @namespace = self.class.namespaces[caller[i].match(/`(.*?)'/)[1]]
      end unless @namespace
      @namespace[1] if @namespace
    end

    def controller
      namespace
      @namespace[0] if @namespace
    end

    module ClassMethods
      def namespaces
        @namespaces ||= {}
      end
      def route_names
        @route_names ||= {}
      end
      def namespaced_filters
        @namespaced_filters ||= []
      end

      def inherited(base)
        base.send(:extend, Cilantro::Controller)
        base.instance_variable_set(:@application, self)
      end
    end
  end
end
