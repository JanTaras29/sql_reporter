lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sql_reporter/version'

Gem::Specification.new do |spec|
  spec.authors       = ["Jan Taras"]
  spec.email         = ["jan.taras29@gmail.com"]
  spec.name          = "sql_reporter"
  spec.version       = SqlReporter::VERSION
  spec.date          = "2019-07-12"
  spec.summary       = "Supplementary Gem to sql_tracker allowing you to compare query data bewteen files"
  spec.homepage      = 'https://github.com/JanTaras29/sql_reporter'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = ['sql_reporter']
  spec.require_paths = ['lib']

  spec.add_dependency('tty-table', '0.10.0')
  spec.add_dependency('gruff', '0.7.0')
  spec.add_dependency('prawn', '2.2.0')
  spec.add_dependency('prawn-table', '0.2.2')
  spec.add_dependency('spreadsheet', '1.2.4')
  spec.add_development_dependency('pry')
end

