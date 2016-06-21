# rubocop:disable Style/FileName
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
require 'sensu-plugin/check/cli'
require 'puppetfiles/bin/check'

# This class implements a CLI to `CheckPuppetfiles`. `Sensu::Plugin::CLI` is a
# pretty handy CLI library.
class PuppetfilesCheck < Sensu::Plugin::CLI
  include Puppetfiles::Bin::Check

  option :exclude,
         long: '--exclude PATHS',
         short: '-x PATHS',
         description: 'Exclude paths matching regexp',
         required: false,
         default: %r{/dev2(-[a-z]+)?/},
         proc: proc { |a| /#{a}/ }

  option :known,
         long: '--known LOCATION',
         short: '-k LOCATION',
         description: 'Repositories known location regexp',
         required: false,
         default: /^git@github\.com:MSMFG/,
         proc: proc { |a| /#{a}/ }

  option :prefix,
         long: '--prefix PATH',
         short: '-p PATH',
         description: 'Puppetfile search base path',
         required: false,
         default: '.'
end
