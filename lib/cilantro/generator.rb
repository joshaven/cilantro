require 'fileutils'
require 'extlib'

module Cilantro
  class Generator
    def create(type, name, data=nil)
      type = type.to_s; name = name.to_s
      unless %w(model controller view).include? type
        raise 'The furst argument of the create method must be one of: model, controller, or view'
      end
      
      if type=='view'
        path = File.join(APP_ROOT, 'app', type.pluralize, name.snake_case, 'new.haml')
      else
        path = File.join(APP_ROOT, 'app', type.pluralize, name.snake_case + '.rb')  
      end

      write_to_file(path, self.send("default_#{type}", name))
    end
    
    
  private
    def default_model(name)
      read_erb File.join(APP_ROOT,'lib','cilantro','generator', 'default_model.erb'), {:name => name}
    end
    
    def default_view(name)
      read_erb File.join(APP_ROOT,'lib','cilantro','generator', 'default_view.erb'), {:name => name}
    end
    
    def default_controller(name)
      read_erb File.join(APP_ROOT,'lib','cilantro','generator', 'default_controller.erb'), {:name => name}
    end
  
    # Write a string or array(of lines of text) to the given full path
    def write_to_file(full_path, data)
      ensure_path File.dirname(full_path)
      File.open(full_path, 'w') {|f| f.write(data.is_a?(Array) ? data.join("\n") : data) }
    end
    
    # Make a folder and any parent folders as needed.
    def ensure_path(*path)
      FileUtils.mkdir_p File.join(path)
    end

    def read_erb(path, locals={})
      # a context to render the erb in
      context = Object.new
      # create instance variable & a getter method for each local variable passed
      locals.each do |k,v|
        context.instance_eval "def #{k};@#{k};end"
        context.send(:instance_variable_set, "@#{k}", v)
      end
      
      begin # try erubis as the erb parser (faster)
        require 'erubis' unless defined? Erubis
        Erubis::Eruby.new IO.read(path)
      rescue # default to erb as the erb parser
        require 'erb' unless defined? ERB
        ERB.new IO.read(path)
      end.result context.instance_eval("binding")
    end
  end
end
