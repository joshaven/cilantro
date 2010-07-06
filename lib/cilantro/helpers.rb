Cilantro.Template.class_eval do
  def stylesheet(file_name, search_path=nil)
    IO.read((search_path || APP_ROOT/'public'/'stylesheets')/'screen.css')
  end

  def javascript(file_name, search_path=nil)
    IO.read((search_path || APP_ROOT/'public'/'javascripts')/'screen.css')
  end

  def image(file_name, search_path=nil)
    IO.read((search_path || APP_ROOT/'public'/'images')/'screen.css')
  end
end