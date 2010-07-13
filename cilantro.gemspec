# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{cilantro}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joshaven Potter"]
  s.date = %q{2010-07-12}
  s.default_executable = %q{cilantro}
  s.description = %q{A framework build on top of Sinatra, boasting automagic gem management, auto-reloading in development, and an innovative way to manage templates.}
  s.email = %q{yourtech@gmail.com}
  s.executables = ["cilantro"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG.md",
     "MIT-LICENSE.md",
     "README.md",
     "Rakefile",
     "TODO.md",
     "VERSION",
     "bin/cilantro",
     "cilantro.gemspec",
     "config.ru",
     "config/init.rb",
     "config/unicorn.conf",
     "lib/cilantro.rb",
     "lib/cilantro/FileMonitor.rb",
     "lib/cilantro/auto_reload.rb",
     "lib/cilantro/base.rb",
     "lib/cilantro/controller.rb",
     "lib/cilantro/dependencies.rb",
     "lib/cilantro/generator.rb",
     "lib/cilantro/generator/README.md",
     "lib/cilantro/generator/Rakefile",
     "lib/cilantro/generator/config.ru",
     "lib/cilantro/generator/database.yml",
     "lib/cilantro/generator/default_controller.erb",
     "lib/cilantro/generator/default_model.erb",
     "lib/cilantro/generator/default_view.erb",
     "lib/cilantro/generator/example_spec.rb",
     "lib/cilantro/generator/favicon.ico",
     "lib/cilantro/generator/gemrc.yml",
     "lib/cilantro/generator/init.rb",
     "lib/cilantro/generator/rspec.rake",
     "lib/cilantro/generator/spec_helper.rb",
     "lib/cilantro/generator/unicorn.conf",
     "lib/cilantro/helpers.rb",
     "lib/cilantro/sinatra.rb",
     "lib/cilantro/system/mysql_fix.rb",
     "lib/cilantro/templater.rb",
     "lib/cilantro/templater/bootstrap.rb",
     "lib/cilantro/templater/erb.rb",
     "lib/cilantro/templater/erubis.rb",
     "lib/cilantro/templater/haml.rb",
     "lib/cilantro/templater/markdown.rb",
     "lib/cilantro/templater/plain.rb",
     "lib/cilantro/thin_proxy.rb",
     "spec/cilantro/auto_reload_spec.rb",
     "spec/cilantro/base_spec.rb",
     "spec/cilantro/controller_spec.rb",
     "spec/cilantro/generator_spec.rb",
     "spec/cilantro/templater_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "tasks/db.rake",
     "tasks/gems.rake",
     "tasks/rdoc.rake",
     "tasks/rspec.rake"
  ]
  s.homepage = %q{http://github.com/joshaven/cilantro}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Web Framework based on Sinatra}
  s.test_files = [
    "spec/cilantro/auto_reload_spec.rb",
     "spec/cilantro/base_spec.rb",
     "spec/cilantro/controller_spec.rb",
     "spec/cilantro/generator_spec.rb",
     "spec/cilantro/templater_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.0"])
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<dm-core>, [">= 0.10.2"])
    else
      s.add_dependency(%q<rack>, [">= 1.0"])
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<dm-core>, [">= 0.10.2"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.0"])
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<dm-core>, [">= 0.10.2"])
  end
end

