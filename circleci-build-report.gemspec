# frozen_string_literal: true

require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'circleci-build-report'
  s.version       = CircleCIBuildReport::VERSION
  s.date          = '2018-05-15'
  s.summary       = 'Export build data for a given project and branch on CircleCI in CSV format'
  s.description   = s.summary
  s.authors       = ['Nassredean Nasseri']
  s.email         = 'dean@vts.com'
  s.homepage      = 'https://github.com/viewthespace/circleci_build_report'
  s.files         = `git ls-files bin lib *.md LICENSE`.split("\n")
  s.executables   = ['circleci_build_report']
  s.require_paths = ['lib']
  s.license       = 'MIT'
end
