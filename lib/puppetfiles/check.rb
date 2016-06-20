require 'puppetfiles'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
module Puppetfiles
  class Puppetfiles
    attr_accessor failures
    class << self
      def failures
        instance.failures ||= []
      end
    end
  end

  # This (MixIn) module contains the logic to be performed on loaded
  # `Puppetfile`s. All methods work assuming there is a `config` method (an
  # `attr_accessor`, for example) that can return a `Hash` of options `:name
  # => value`.
  module Check
    # Load all puppetfiles, yield to a check block, and then report.
    #
    # @param puppetfiles [Array<String>] A list of paths to load
    #
    # @example
    #   describe Dir['provisioning/Puppefile.*'] do
    #     puts 'should do something'
    #   end
    def describe(puppetfiles)
      Puppetfiles.load puppetfiles
      yield
      respond_to? :report && report
    end

    # Run a compliance chek on all the modules in a `Puppetfile`
    #
    # @param check   [String] The check short description
    # @param failing [Proc]   A block to yield to, for compliance checking
    #
    # @example
    #   they 'should have less then 10 modules' do |puppetfile|
    #     puppetfile[:modules].count < 10
    #   end
    def they(check, &failing)
      Puppetfiles.loaded.reject(&failing).each do |puppetfile|
        Puppetfiles.failures << [check, puppetfile[:path]]
      end
    end

    # Run a compliance chek on all the modules in a `Puppetfile`
    #
    # @param check   [String] The check short description
    # @param failing [Proc]   A block to yield to, for compliance checking
    #
    # @example
    #   modules 'should use https' do |mod|
    #     !mod[:git] || mod[:git].match('^https://')
    #   end
    def modules(check, &failing)
      Puppetfiles.loaded.each do |puppetfile|
        puppetfile[:modules].reject(&failing).each do |mod|
          # Easy to read if sorted. `output` can be mocked for testing.
          Puppetfiles.failures << [check, puppetfile[:path], mod[:name]]
        end
      end
    end
  end
end
