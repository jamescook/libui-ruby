require File.expand_path('../lib/mysql2/version', __FILE__)

Mysql2::GEMSPEC = Gem::Specification.new do |s|
  s.name = 'libui'
  s.version = LibUI::VERSION
  s.authors = ['James Cook', 'Marwan Rabbâa']
  s.email = ['jcook.rubyist@gmail.com', 'waghanza@gmail.com']
  s.homepage = 'http://github.com/jamescook/libui-ruby'
  s.summary = 'FFI binding for libui'
  s.files = `git ls-files README.md LICENSE lib`.split
end
