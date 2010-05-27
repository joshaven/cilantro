require 'fileutils'
require 'extlib'

module Cilantro
  class Generator
    def create(type, name=nil, data=nil)
      type = type.to_s; name = name.to_s
      unless %w(model controller view framework).include? type
        raise 'The furst argument of the create method must be one of: model, controller, or view'
      end
      
      return default_framework_structure() if type == 'framework'

      if type=='view'
        path = File.join(APP_ROOT, 'app', type.pluralize, name.snake_case, 'new.haml')
      else
        path = File.join(APP_ROOT, 'app', type.pluralize, name.snake_case + '.rb')  
      end

      write_to_file(path, self.send("default_#{type}", name))
    end
    
    
  private
    def default_framework_structure()
      [ File.join(APP_ROOT,'app','models'),
        File.join(APP_ROOT,'app','controllers'),
        File.join(APP_ROOT,'app','views'),
        File.join(APP_ROOT,'config'),
        File.join(APP_ROOT,'db'),
        File.join(APP_ROOT,'gems'),
        File.join(APP_ROOT,'lib'),
        File.join(APP_ROOT,'public','images'),
        File.join(APP_ROOT,'public','javascripts'),
        File.join(APP_ROOT,'public','stylesheets'),
        File.join(APP_ROOT,'tasks')
        File.join(APP_ROOT,'spec')
      ].each {|path| ensure_path path}
      write_to_file File.join(APP_ROOT,'README.md'), get_template('README.md')
      write_to_file File.join(APP_ROOT,'Rakefile'), get_template('Rakefile')
      write_to_file File.join(APP_ROOT,'config','init.rb'), get_template('init.rb')
      write_to_file File.join(APP_ROOT,'config','unicorn.conf'), get_template('unicorn.conf')
      write_to_file File.join(APP_ROOT,'config.ru'), get_template('config.ru')
      write_to_file File.join(APP_ROOT,'config','database.yml'), get_template('database.yml')
      write_to_file File.join(APP_ROOT,'gems','gemrc.yml'), get_template('gemrc.yml')
      write_to_file File.join(APP_ROOT,'tasks','rspec.rake'), get_template('rspec.rake')
      write_to_file File.join(APP_ROOT,'spec','spec_helper.rb'), get_template('spec_helper.rb')
    end
  
    def default_model(name)
      get_template 'default_model.erb', {:name => name.singularize}
    end
    
    def default_view(name)
     get_template 'default_view.erb', {:name => name}
    end
    
    def default_controller(name)
      get_template 'default_controller.erb', {:name => name.pluralize}
    end
  
    # Write a string or array(of lines of text) to the given full path
    def write_to_file(full_path, data)
      ensure_path File.dirname(full_path)
      File.open(full_path, 'w') {|f| f.write(data.is_a?(Array) ? data.join("\n") : data) } unless File.exists?(full_path)
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
      rescue LoadError # default to erb as the erb parser
        require 'erb' unless defined? ERB
        ERB.new IO.read(path)
      end.result context.instance_eval("binding")
    end

    def get_template(name, locals={})
      if /\.erb$/ =~ name
        read_erb File.join(CILANTRO_ROOT,'lib','cilantro','generator', name), locals
      else
        IO.read File.join(CILANTRO_ROOT,'lib','cilantro','generator', name)
      end
    end
  end
end
