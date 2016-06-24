require 'puppetfiles'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
module Puppetfiles
  # This (MixIn) module contains the logic to be performed on loaded
  # `Puppetfile`s. All methods work assuming there is a `config` method (an
  # `attr_accessor`, for example) that can return a `Hash` of options `:name
  # => value`.
  module Bin
    # Remove 1 module details in all provided puppetfiles that contain it
    module RemoveModule
      # Run the module remove procedure
      def run
        mod = argv.first
        files = argv.drop(1)
        ::Puppetfiles.load files
        ::Puppetfiles.remove mod
        loaded = ::Puppetfiles.loaded.count
        updated = ::Puppetfiles.loaded.count
        ::Puppetfiles.save
        ok "#{loaded} Puppetfiles, `#{mod}' removed from #{updated}"
      end
    end
  end
end
