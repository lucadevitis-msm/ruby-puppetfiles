# rubocop:disable Style/FileName
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
require 'sensu-plugin/check/cli'
require 'puppetfiles/update'

# See `Puppetfiles::Repo.load_all`
include Puppetfiles::Mock

# This class implements a CLI to `CheckPuppetfiles`. `Sensu::Plugin::CLI` is a
# pretty handy CLI library.
class CheckPuppetfiles < Sensu::Plugin::CLI

  include Puppetfiles::Bin::Update

end
