# frozen_string_literal: true

require 'date'

GEM_NAME = 'rxsd'
PKG_VERSION = '0.6.0'

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = PKG_VERSION
  s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.executables << 'xsd_to_ruby' << 'rxsd_test'

  s.required_ruby_version = '>= 1.8.1'
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.3')

  s.add_dependency('activesupport', '> 3.2')
  s.add_dependency('libxml-ruby', '> 2.8.0')
  s.add_development_dependency('rspec', '> 2.12.0')

  s.author = 'Mo Morsi'
  s.email = 'mo@morsi.org'
  s.date = Date.today.to_s
  s.description = 'A library to translate xsd schemas and xml implementations into ruby classes/objects'
  s.summary = 'A library to translate xsd schemas and xml implementations into ruby classes/objects'
  s.homepage = 'http://morsi.org/projects/RXSD'
end
