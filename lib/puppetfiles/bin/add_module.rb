require 'puppetfiles'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
module Puppetfiles
  # This (MixIn) module contains the logic to be performed on loaded
  # `Puppetfile`s. All methods work assuming there is a `config` method (an
  # `attr_accessor`, for example) that can return a `Hash` of options `:name
  # => value`.
  module Bin
    # Update 1 module details in all provided puppetfiles that contain it
    module AddModule
      # Run the module update
      def run
        mod = argv.first
        files = argv.drop(1)
        version = config[:version]
        keys = [:git, :ref]
        options = keys.map { |k| [k, config[k]] if config[k] }.compact.to_h
        ::Puppetfiles.load files
        ::Puppetfiles.add mod, version, options
        loaded = ::Puppetfiles.loaded.count
        ::Puppetfiles.save
        ok "#{mod} has been added to #{loaded} Puppetfiles"
      end
    end
  end
end
