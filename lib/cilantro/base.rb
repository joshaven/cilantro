module Cilantro
  class << self
    def env(e=nil)
      # Sinatra::Base.environment
      true
    end
    
    def load_environment(options={})
      option_defaults!
      options.each {|k,v| Sinatra::Base.set k, v}
      
      # load models
      begin
        # try = 0
        Dir.glob(Sinatra::Base.models/'*.rb').each {|model| require model}
      rescue
        # try += 1
        # setup_database # ensure that DataMapper is connected to the database
        # retry unless try > 1
        raise "Could not load models, check model syntax or database settings"
      end

      # load controllers unless we are in IRB
      Dir.glob(Sinatra::Base.controllers/'*.rb').each {|file| require file} unless env == 'irb'
      
      # load lib files
      Dir.glob(Sinatra::Base.lib/'*.rb').each {|file| require file }
    end
    
    def setup_database
      
    end
  private
    def option_defaults!
      Sinatra::Base.set :lib, APP_ROOT/'lib'
      Sinatra::Base.set :models, APP_ROOT/'app'/'models'
      Sinatra::Base.set :controllers, APP_ROOT/'app'/'controllers'
    end
  end
  
end
  