require 'yaml'
require 'rubygems'
require 'rubygems/custom_require'

module Cilantro
  class << self
    def gems
      @gems ||= {}
    end

    def add_gem(name, options)
      if gems[name]
        gems[name].merge!(options)
      else
        gems[name] = options
      end
      if env == 'development'
        open(".gems", 'w') do |f|
          gems.keys.sort.each do |name|
            options = gems[name]
            next if options[:only_env] == 'development'
            gem_def = name.dup
            gem_def << " --version '#{options[:version]}'" if options[:version]
            f << gem_def << "\n"
          end
        end if File.writable?('.gems') # this won't run if the file doesn't exist either :)
      end
    end

    def install_missing_gems
      Dir.chdir APP_ROOT unless Dir.pwd == APP_ROOT
      
      gempath = begin
        YAML::load_file(APP_ROOT/'gems'/'gemrc.yml')['gempath'].first
      rescue
        "#{APP_ROOT}/gems"
      end
      
      return unless File.exists?(gempath)

      # Redirect standard output to the netherworld
      no_debug = '2>&1 >/dev/null'

      all_gems = ""
      # Ensure each gem in gems/cache is installed
      Dir.glob("#{gempath}/cache/*.gem").each do |gem_name|
        gem_name = gem_name.match(/([^\/]+)\.gem/)[1]
        j, name, version = *gem_name.match(/^(.*)-([\d\.]+)$/)
        Cilantro.add_gem(name, :version => version)
        if !File.exists?("#{gempath}/gems/#{gem_name}")
          puts "Installing gem: #{gem_name}"
          pristined = `gem pristine --config-file gems/gemrc.yml -v #{version} #{name}`
          if $?.success?
            puts pristined
          else
            direct = `gem install --config-file gems/gemrc.yml gems/cache/#{gem_name}.gem`
            if $?.success?
              puts direct
            else
              puts `gem install --config-file gems/gemrc.yml #{version} #{name}`
            end
          end
          # LEAVE THIS HERE FOR LATER REFERENCE - These two commands unpack gems folders. Might be quicker than gem pristine? (but doesn't compile any gem binary libraries)
          # `mkdir -p #{gempath}/gems/#{gem_name} #{no_debug}`
          # `tar -Oxf #{gempath}/cache/#{gem_name}.gem data.tar.gz | tar -zx -C #{gempath}/gems/#{gem_name}/ #{no_debug}`
        end
      end
    end
  end
end

# 2. Each dependency should:
#   a) Require the dependency.
#   b) If not installed and is possible to install, INSTALL IT.
#   c) If in development, and dependency is needed in production, write itself to .gems.
module Kernel
  def debugger
    dependency 'ruby-debug'
    debugger
  end

  # TODO: support all gem installation options, currently, the options hash will only deal with :version
  def dependency(name, options={})
    if [options[:env] ||= ENV['RACK_ENV']].flatten.collect {|e| e.to_s}.include? ENV['RACK_ENV']
      begin
        require name
      rescue LoadError
        if File.directory?("#{APP_ROOT}/gems") && File.writable?("#{APP_ROOT}/gems")
          puts "Installing gem locally: #{options[:gem] || name}..."
          puts `gem install --config-file gems/gemrc.yml #{'-v "'+options[:version].gsub(' ','')+'"' if options[:version]} #{options[:gem] || name}`
          Gem.use_paths("#{APP_ROOT}/gems", ["#{APP_ROOT}/gems"])
          begin
            require name
          rescue LoadError => e
            puts "(Error installing gem: `#{name}')\n#{e.inspect}"
            puts ">> Load Path: #{$:.join("\n")}\n>> Gem Path: #{Gem.path.inspect}"
          end
        else
          raise
        end
      end
    end
    Cilantro.add_gem(options[:gem] || name, options)
  end
end

# 1. Sandbox Rubygems
if File.directory?("#{APP_ROOT}/gems")
  # Oh but first, go ahead and install any missing gems (PLEASE, only include gems/specifications and gems/cache in your git repo)
    Cilantro.install_missing_gems if File.writable?("#{APP_ROOT}/gems")
  Gem.use_paths("#{APP_ROOT}/gems", ["#{APP_ROOT}/gems"])
end
