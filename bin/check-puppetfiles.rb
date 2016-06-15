# rubocop:disable Style/FileName
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
require 'sensu-plugin/check/cli'
require 'puppetfiles/check'

# See `Puppetfiles::Repo.load_all`
include Puppetfiles::Mock

# This class implements a CLI to `CheckPuppetfiles`. `Sensu::Plugin::CLI` is a
# pretty handy CLI library.
class CheckPuppetfiles < Sensu::Plugin::CLI
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

  include Puppetfiles::Bin::Check

end
