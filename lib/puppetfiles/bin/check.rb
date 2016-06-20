require 'puppetfiles/check'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
module Puppetfiles
  # This (MixIn) module contains the logic to be performed on loaded
  # `Puppetfile`s. All methods work assuming there is a `config` method (an
  # `attr_accessor`, for example) that can return a `Hash` of options `:name
  # => value`.
  module Bin
    module CheckProvisioning
      include Puppetfiles::Check
      def report
        message = "#{Puppetfiles.loaded.count} Puppetfiles, " +
                  "#{Puppetfiles.failures.count} failures"
        ok message if Puppetfiles.failures.empty?
        details = proc {|info| "\n" + info.join(': ')}
        critical message + Puppetfiles.failures.collect(&details).join
      end

      attr_accessor puppetfiles

      def run
        puppetfiles = Dir["#{config[:prefix]}/**/Puppetfile.*"]
        puppetfiles.reject! { |p| p.match(config[:exclude]) }
        describe puppetfiles do
          modules 'should be versioned' do |mod|
            mod[:version] || (mod[:options][:git] && mod[:options][:ref])
          end
          modules 'should came from known git repo' do |mod|
            !mod[:options][:git] || mod[:options][:git].match(config[:known]))
          end
        end
      end
  end
end
