require 'fileutils'

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
      [ 
        "class #{name.camel_case}",
        '  include DataMapper::Resource',
        '',
        '  property :id, Serial',
        '  property :data, String',
        '  property :created_at, DateTime',
        '  property :updated_at, DateTime',
        'end' 
      ].join("\n")
    end
    
    def default_view(name)
      "%p Greetings from the #{name} view.  Please edit this file."
    end
    
    def default_controller(name)
      [
        "class #{name.camelcase} < Application",
        "  namespace '/#{name}/'",
        "",
        "  get :new do",
        "    @#{name.singularize.snake_case} = #{name.singularize.camel_case}.new",
        "    view :index",
        "  end",
        "end"
      ].join("\n")
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
  end
end
