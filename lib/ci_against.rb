require 'optparse'
require 'psych'
require 'octokit'
require 'tempfile'
require 'securerandom'

require "ci_against/version"
require 'ci_against/converter'
require 'ci_against/travis_yml'
require 'ci_against/cli'
require 'ci_against/runner'

module CIAgainst
end
