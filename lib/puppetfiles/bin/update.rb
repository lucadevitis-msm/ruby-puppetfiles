require 'puppetfiles'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
module Puppetfiles
  module Bin
    # This (MixIn) module contains the logic to be performed on loaded
    # `Puppetfile`s. All methods work assuming there is a `config` method (an
    # `attr_accessor`, for example) that can return a `Hash` of options `:name
    # => value`.
    module Update
      def run
      end
    end
  end
end
