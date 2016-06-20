require 'puppetfiles'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
module Puppetfiles
  # This (MixIn) module contains the logic to be performed on loaded
  # `Puppetfile`s. All methods work assuming there is a `config` method (an
  # `attr_accessor`, for example) that can return a `Hash` of options `:name
  # => value`.
  module Bin
    module UpdateModule
      include Puppetfiles

      def run
        Puppetfiles.load argv[1,-1]
        Puppetfiles.update argv[0],
                           version: config[:version],
                           options: {
                             git: config[:git],
                             ref: config[:ref] }
        Puppetfiles.save
        ok "#{Puppetfiles.loaded.count} Puppetfiles, " +
           "#{Puppetfiles.updated.count} updated"
      end
  end
end
