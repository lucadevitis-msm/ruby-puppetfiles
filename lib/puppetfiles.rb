require 'puppetfiles/version'
require 'singleton'
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
      version = args[0].is_a?(String) ? args[0] : nil
      options = args[-1].is_a?(Hash) ? args[-1] : {}
      Repo.puppetfiles.loaded[-1][:modules] << {
        name: name,
        version: version,
        options: options
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
  class Repo
    # There must be a single instance only.
    include Singleton

    # @return [Array] The details of loaded files
    def loaded
      @loaded ||= []
    end

    class << self
      # Just for readability...
      alias puppetfiles instance

      # Load all the `Puppetfiles` from the list. If a block is given, then
      # load all files for which the block returns `true`. You must include
      # `Puppetfiles::Mock` module at script level so that loaded `Puppetfile`s
      # do not raise `NoMethodError`.
      #
      # @param puppetfiles [Array<String>] The list of paths to load from
      def load_all(files)
        files.each do |file|
          if !block_given? || yield(file)
            puppetfiles.loaded << { path: file, modules: [] }
            load(file)
          end
        end
      end

      # Prints error messages for each `Puppetfile` with a module that fails to
      # comply the ckeck in the given block.
      #
      # @param message [String] The error message to print
      # @param output [#<<]     The output handler
      # @param failing          A block to yield to, for compliance checking
      def check_modules(message, output = $stdout, &failing)
        puppetfiles.loaded.each do |puppetfile|
          puppetfile[:modules].select(&failing).each do |details|
            # Easy to read if sorted. `output` can be mocked for testing.
            output << "E: #{puppetfile[:path]}: #{message}: #{details}\n"
          end
        end
      end

      # Update modules details on all loaded files. `updated` must be an
      # `Array` of `Hash`es with the following keys:
      #
      # `:name`: The name of the module (required)
      # `:version`: The version number (optional)
      # `:options`: An `Hash` of additional options (optional)
      #
      # `:options` keys, if any, are:
      #
      # `:git`: The git repo URL (optional)
      # `:ref`: The git ref string (optional)
      #
      # @param updated [Array] An array of modules details
      def update_modules(updated)
        puppetfiles.loaded.each do |puppetfile|
          puppetfile[:modules].each_index do |curernt|
            name = puppetfile[:modules][curernt][:name]
            module_ = updated.find_index {|m| m[:name] == name}
            puppetfile[:modules][curernt] = updated[module_] if module_
          end
        end
      end

      # Dump all the loaded `Puppetfile`s
      def dump_all
        puppetfiles.loaded.each do |puppetfile|
          File.open puppetfile[:path], 'w' do |file|
            file.print "# Automatically updated on #{Time.now}"
            puppetfile[:modules].each do |mod_|
              file.print "\nmod '#{mod_[:name]}'"
              file.print ", '#{mod_[:version]}'" if mod_[:version]
              (mod_[:options] || {}).each do |name, value|
                file.print ",\n  :#{name} => '#{value}'"
              end
            end
          end
        end
      end
    end
  end
end
