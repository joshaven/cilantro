require File.expand_path File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Cilantro' do
  describe 'AutoReloader' do
    describe 'auto-reloading' do
      after :each do
        Cilantro.instance_variable_get('@reloader').stop_child if Cilantro.instance_variable_get('@reloader').is_a?(Cilantro::AutoReloader)
        cleanup_view :scrap_file
      end
      
      it 'should know when an existing file has changed' do
        # Note: @reloader is generally internally accessed through the :app method but we need to shortcut the :auto_reload method
        write_to_view :scrap_file, "<p>Created on: #{Time.now}</p>"
        Cilantro.instance_variable_set '@reloader', Cilantro::AutoReloader.new
        Cilantro.instance_variable_get('@reloader').app_updated?.should be_false
        sleep 1
        write_to_view :scrap_file, "<p>Created on: #{Time.now}</p>"
        Cilantro.instance_variable_get('@reloader').app_updated?.should be_true
      end

      it 'should self close the AutoReloader when there is no parent process'
      
      it 'should pickup on newly added files' do
        # Note: @reloader is generally internally accessed through the :app method but we need to shortcut the :auto_reload method
        cleanup_view :scrap_file # ensure it doesn't exist
        Cilantro.instance_variable_set '@reloader', Cilantro::AutoReloader.new # start watching the files
        write_to_view :scrap_file, "<p>Created on: #{Time.now}</p>" # create a new file to be watched
        pending do # doesn't notice new file... needs to scan directory
          Cilantro.instance_variable_get('@reloader').app_updated?.should be_true
        end        
      end
      
      it 'should be ok with files that dissapear' do
        # Note: @reloader is generally internally accessed through the :app method but we need to shortcut the :auto_reload method
        write_to_view :scrap_file, "<p>Created on: #{Time.now}</p>"
        Cilantro.instance_variable_set '@reloader', Cilantro::AutoReloader.new
        Cilantro.instance_variable_get('@reloader').app_updated?.should be_false
        cleanup_view :scrap_file
        pending do # Should not get: "No such file or directory" error
          Cilantro.instance_variable_get('@reloader').app_updated?.should be_true
        end
      end
    end
  end
end


def write_to_view(name, string)
  view_path = File.join APP_ROOT, 'app', 'views', "#{name}.haml"
  File.open(view_path, 'w') {|f| f.write(string) }
end

def cleanup_view(name)
  path = File.join APP_ROOT, 'app', 'views', "#{name}.haml"
  File.delete(path) if File.exists?(path)
end