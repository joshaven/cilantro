require 'fileutils'
require 'extlib'

module Cilantro
  class Generator
    # eg:  create model People
    # eg:  create controller People
    # eg:  create view People
    def create(type, name=nil, data=nil)
      type = type.to_s; name = name.to_s
      unless %w(model controller view framework).include? type
        raise 'The furst argument of the create method must be one of: model, controller, or view'
      end
      
      return build_default_framework_structure() if type == 'framework'

      # Normalize name as: singular snake_case
      name = name.gsub(/\W/, '_').snake_case.singularize

      case type.to_s.downcase
      when 'view'
        path = APP_ROOT/'app'/type.pluralize/name/'new.html.haml'
      when 'controller'
        path = APP_ROOT/'app'/type.pluralize/name.pluralize + '.rb'
      when 'model'
        path = APP_ROOT/'app'/type.pluralize/name + '.rb'
      end

      write_to_file(data || self.send("default_#{type}", name), path)
    end

  private
    def build_default_framework_structure()
      [ APP_ROOT/'app'/'models',
        APP_ROOT/'app'/'controllers',
        APP_ROOT/'app'/'views',
        APP_ROOT/'app'/'views'/'layouts',
        APP_ROOT/'app'/'views'/'shared',
        APP_ROOT/'config',
        APP_ROOT/'db',
        APP_ROOT/'gems',
        APP_ROOT/'lib',
        APP_ROOT/'public'/'images',
        APP_ROOT/'public'/'javascripts',
        APP_ROOT/'public'/'stylesheets',
        APP_ROOT/'tasks',
        APP_ROOT/'spec'
      ].each {|path| ensure_path path}
      write_to_file get_template('README.md'), APP_ROOT/'README.md'
      write_to_file get_template('Rakefile'), APP_ROOT/'Rakefile'
      write_to_file get_template('init.rb'), APP_ROOT/'config'/'init.rb'
      write_to_file get_template('unicorn.conf'), APP_ROOT/'config'/'unicorn.conf'
      write_to_file get_template('config.ru'), APP_ROOT/'config.ru'
      write_to_file get_template('database.yml'), APP_ROOT/'config'/'database.yml'
      write_to_file get_template('gemrc.yml'), APP_ROOT/'gems'/'gemrc.yml'
      write_to_file get_template('rspec.rake'), APP_ROOT/'tasks'/'rspec.rake'
      write_to_file get_template('spec_helper.rb'), APP_ROOT/'spec'/'spec_helper.rb'
      write_to_file get_template('example_spec.rb'), APP_ROOT/'spec'/'example_spec.rb'
      copy_file 'favicon.ico', APP_ROOT/'public'/'favicon.ico'
      copy_file 'Blk2Wh150x1.gif', APP_ROOT/'public'/'images'/'Blk2Wh150x1.gif'
      copy_file 'cilantro_100x130.gif', APP_ROOT/'public'/'images'/'cilantro_100x130.gif'
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
    def write_to_file(data, full_path)
      ensure_path File.dirname(full_path)
      File.open(full_path, 'w') {|f| f.write(data.is_a?(Array) ? data.join("\n") : data) } unless File.exists?(full_path)
    end
    
    def copy_file(file_name, destination_path)
      FileUtils.copy(CILANTRO_ROOT/'lib'/'cilantro'/'generator'/file_name, destination_path)
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
        read_erb CILANTRO_ROOT/'lib'/'cilantro'/'generator'/name, locals
      else
        IO.read CILANTRO_ROOT/'lib'/'cilantro'/'generator'/name
      end
    end
  end
end
