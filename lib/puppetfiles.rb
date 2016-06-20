require 'puppetfiles/version'
require 'puppetfiles/mock'
require 'singleton'
require 'time'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>

module Puppetfiles
  # The methods in this module basically mock the `Puppetfile`'s syntax, so we
  # don't need to parse it: just load the file and let Ruby do the rest.
  # Luca's Lazy Bastard Approach.
  module Mock
    # Mock the `Puppetfile`'s `mod` function call. It actually builds
    # `Repo.puppetfiles.loaded` data structure about loaded `Puppetfile`s and
    # their modules.
    def mod(name, *args)
      raise SyntaxError, "Module name is not a String" unless name.is_a?(String)
      Repo.puppetfiles.loaded[-1][:modules] << {
        name: name,
        version: args[0].is_a?(String) ? args[0] : nil,
        options: args[-1].is_a?(Hash) ? args[-1] : {}
      }
    end

    # Mock the `Puppetfile`'s `forge` function call.
    # We are not interested in supporting multiple forges right now.
    # @param _ discarded
    def forge(_)
      yield if block_given?
    end

    # Mock the `Puppetfile`'s `exclusion` function call.
    # @param * discarded
    def exclusion(*)
    end

    # Mock the `Puppetfile`'s `metadata` function call.
    def metadata
    end
  end

  # This class provides the methods to work on a repository of `Puppetfile`s.
  class Puppetfiles
    # There must be a single instance only.
    include Singleton

    # @return [Array] The details of loaded `Puppetfile`s
    attr_accessor loaded

    class << self
      # @return [Array] The details of loaded `Puppetfile`s
      def loaded
        instance.loaded ||= []
      end

      # Load all the `Puppetfile`s from the list. If a block is given, then
      # load all files for which the block returns `true`. You must include
      # `Puppetfiles::Mock` module at script level so that loaded `Puppetfile`s
      # do not raise `NoMethodError`.
      #
      # @param files [Array<String>] The list of paths to load from
      def load(files)
        include Puppetfiles::Mock
        loaded.clear
        files.each do |file|
          if !block_given? || yield(file)
            loaded << { path: file, modules: [] }
            Kernel::load(file)
          end
        end
      end

      def update(name, new)
        updated << loaded.collect do |puppetfile|
          outdated = puppetfiles[:modules].detect { |mod| mod[:name] == name }
          next unless outdated
          outdated[:version] = new[:version] if new[:version]
          outdated[:options] ||= {}
          new[:options].each { |k,v| outdated[:options][k] = v if v }
          puppetfile
        end.compact
      end

      # Dump `Puppetfile`s
      #
      # @param puppetfiles Either `:loaded` or `:updated`
      def dump(puppetfiles)
        puppetfiles.each do |puppetfile|
          File.open puppetfile[:path], 'w' do |file|
            file.print "# Automatically dumped on #{Time.now}"
            puppetfile[:modules].each do |mod|
              file.print "\nmod '#{mod[:name]}'"
              file.print ", '#{mod[:version]}'" if mod[:version]
              (mod[:options] || {}).each do |name, value|
                file.print ",\n  :#{name} => '#{value}'" if value
              end
            end
          end
        end
      end

      def save
        dump updated.uniq { |puppetfile| puppetfile[:path] }
      end
    end
  end
end
