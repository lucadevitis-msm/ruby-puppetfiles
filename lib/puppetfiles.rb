require 'puppetfiles/version'
require 'singleton'
require 'time'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>

# Module to handle `Puppetfile`s manupulation and testing
module Puppetfiles
  # Utility function to extract version from list of arguments.
  #
  # @param args [#first] List of arguments
  # @return     [String] version
  def self.mod_version(*args)
    args.first.is_a?(String) ? args.first : ''
  end

  # Utility function to extract options from list of arguments
  #
  # @param args [#last] List of arguments
  # @return     [Hash]  options
  def self.mod_options(*args)
    args.last.is_a?(Hash) ? args.last : {}
  end

  # @return [Array] The details of the loaded `Puppetfile`s
  def self.loaded
    Puppetfiles.instance.loaded
  end

  # @return [Array] The details of the modified `Puppetfile`s
  def self.updated
    Puppetfiles.instance.updated
  end

  # Load one `Puppetfile` and returns the modules list
  #
  # @param file [String]      The Puppetfile path
  # @return     [Array<Hash>] The list of loaded modules
  def self.load(file)
    loaded << { path: file, modules: [] }
    Kernel.load(file)
    loaded.last[:modules]
  end

  # Load all the `Puppetfile`s from the list. If a block is given, then
  # load all files for which the block returns `true`.
  #
  # @param files [Array<String>] The list of paths to load from
  def self.load_all(files)
    loaded.clear
    files.map do |file|
      load(file)
    end
  end

  # Update module `name` on all loaded `Puppetfile`s
  #
  # @param (see #mod)
  # @return [Array<Hash>] The list of updated `Puppetfile`s
  def self.update_all(name, *args)
    version = mod_version(*args)
    options = mod_options(*args)
    loaded.collect do |puppetfile|
      outdated = puppetfile[:modules].detect { |mod| mod[:name] == name }
      next unless outdated
      outdated[:version] = version
      options.each { |k, v| outdated[:options][k] = v }
      updated << puppetfile unless updated.include?(puppetfile)
      puppetfile
    end.compact
  end

  # Add a module to all loaded `Puppetfile`s
  #
  # @param (see #Puppetfiles::Mock::mod)
  # @return [Array<Hash>] The list of updated `Puppetfile`s
  def self.add_all(name, *args)
    version = mod_version(*args)
    options = mod_options(*args)
    loaded.each do |puppetfile|
      puppetfile[:modules] << {
        name: name,
        version: version,
        options: options }
      updated << puppetfile unless updated.include?(puppetfile)
    end
  end

  # Rmove module `name` from each loaded `Puppetfile`
  #
  # @param name [String] The name of the module to remove
  # @return [Array<Hash>] The list of updated `Puppetfile`s
  def self.remove_all(name)
    loaded.select do |puppetfile|
      next unless puppetfile[:modules].reject! { |m| m[:name] == name }
      updated << puppetfile unless updated.include?(puppetfile)
      puppetfile
    end.compact
  end

  # Dump an `Array` of `Hash`es as the content of Puppetfile
  #
  # @param path     [String]      The `Puppetfile`'s path
  # @param modules  [Array<Hash>] The list of modules
  def self.dump(path, modules)
    File.open path, 'w' do |file|
      update_message = ENV['UPDATE_MESSAGE'] || "Updated on #{Time.now}"
      file.print '# ', update_message
      modules.sort_by { |mod| mod[:name] }.each do |mod|
        # mod list might be parsed from another source format like JSON
        # or YAML file
        version = mod[:version] || ''
        options = mod[:options] || {}
        file.print "\nmod '#{mod[:name]}'"
        file.print ", '#{version}'" unless version.empty?
        options.each do |name, value|
          file.print ",\n  :#{name} => '#{value}'" if value
        end
      end
    end
  end

  # Dump `Puppetfile`s. Use `save` unless you know what you are dumping.
  #
  # @see load
  #
  # @param puppetfiles [Array] List of `Puppetfile`s details to dump
  # @return            [Array] List of dumped `Puppetfile`s details
  def self.dump_all(puppetfiles)
    puppetfiles.each do |puppetfile|
      dump puppetfile[:path], puppetfile[:modules]
    end
  end

  # Dumps modified `Puppetfile`s and clear `updated`.
  # @see updated
  def self.save_all
    dump_all updated
    updated.clear
  end

  # The methods in this module basically mock the `Puppetfile`'s syntax, so we
  # don't need to parse it: just load the file and let Ruby do the rest.
  # Luca's Lazy Bastard Approach.
  module Mock
    # Mock the `Puppetfile`'s `mod` function call. It actually builds
    # `Repo.puppetfiles.loaded` data structure about loaded `Puppetfile`s and
    # their modules.
    def mod(name, *args)
      Puppetfiles.instance.loaded.last[:modules] << {
        name: name,
        version: ::Puppetfiles.mod_version(*args),
        options: ::Puppetfiles.mod_options(*args) }
    end

    # Mock the `Puppetfile`'s `forge` function call.
    # We are not interested in supporting multiple forges right now.
    # @param _ discarded
    def forge(_)
      yield if block_given?
    end

    # Mock the `Puppetfile`'s `exclusion` function call.
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

    # The details of loaded `Puppetfile`s
    def loaded
      @loaded ||= []
    end

    # The details of modified `Puppetfile`s
    def updated
      @updated ||= []
    end
  end
end

include Puppetfiles::Mock
