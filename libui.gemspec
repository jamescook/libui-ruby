require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'libui'
  s.version = LibUI::VERSION
  s.authors = ['James Cook', 'Marwan Rabbâa']
  s.email = ['jcook.rubyist@gmail.com', 'waghanza@gmail.com']
  s.homepage = 'http://github.com/jamescook/libui-ruby'
  s.summary = 'FFI binding for libui'
  s.files = `git ls-files README.md LICENSE lib`.split

  s.add_runtime_dependency 'ffi', '~> 1.9', '>= 1.9.14'

  s.test_files = `git ls-files spec examples`.split
end
