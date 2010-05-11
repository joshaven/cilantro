# $:.unshift('lib')
require File.join File.dirname(__FILE__), 'lib', 'cilantro'
 
Gem::Specification.new do |s|
  s.author = 'Joshaven Potter'
  s.email = 'yourtech@gmail.com'
  s.homepage = 'http://github.com/joshaven/cilantro'
 
  s.name = 'cilantro'
  s.version = Cilantro::VERSION::STRING
  s.platform = Gem::Platform::RUBY
  s.summary = 'Cilantro Framework'
  s.description = 'Cilantro web development framework' + 
    'Web development framework based upon Sinatra.'
  s.rubyforge_project = 'cilantro'
 
  s.files = Dir['CHANGELOG.md', 'MIT-LICENSE.md', 'README.md', 'lib/**/*', 'spec/**/*']
  s.has_rdoc = true
  s.require_path = 'lib'
  s.requirements << 'none'
 
  # note: I have not tried with older versions of any of the dependencies below
  # s.add_dependency 'dm-core',     '~> 0.10.2' 
  # s.add_dependency 'do_sqlite3',  '~> 0.10.1.1' # only needed for testing
  
  s.add_dependency 'rspec',       '~> 1.3.0'    # only needed for testing
  s.add_dependency 'yard',        '~> 0.5.4'    # only for rdoc generation
end
