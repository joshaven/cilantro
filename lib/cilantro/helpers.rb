module Cilantro
  module Helpers
    def static(filename, search_path=nil)
      IO.read((search_path || APP_ROOT/'public')/filename)
    end
    
    def stylesheet(file_name, search_path=nil)
      static file_name, (search_path || APP_ROOT/'public'/'stylesheets')
    end

    def javascript(file_name, search_path=nil)
      static file_name, (search_path || APP_ROOT/'public'/'javascripts')
    end

    def image(file_name, search_path=nil)
      static file_name, (search_path || APP_ROOT/'public'/'imagess')
    end
  end
end
