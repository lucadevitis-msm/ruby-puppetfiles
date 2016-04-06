require 'puppetfiles'
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
module Puppetfiles
  # This (MixIn) module contains the logic to be performed on loaded
  # `Puppetfile`s. All methods work assuming there is a `config` method (an
  # `attr_accessor`, for example) that can return a `Hash` of options `:name
  # => value`.
  module Check
    # Load all `Puppetfile`s from configured `config[:prefix]`
    def load_all_puppetfiles
      Repo.load_all Dir.glob("#{config[:prefix]}/**/Puppetfile.*") do |file|
        !file.match(config[:exclude])
      end
    end

    # Print all `Puppetfile`s that load modules with no version information
    def check_modules_version
      Repo.check_modules('No version') do |mod_|
        !(mod_[:version] || (mod_[:options][:git] && mod_[:options][:ref]))
      end
    end

    # Print all `Puppetfile`s that download a module from an unknown repo
    def check_modules_repo_location
      Repo.check_modules('Unknown repo') do |mod_|
        repo = mod_[:options][:git]
        !(repo.nil? || repo.match(config[:known]))
      end
    end
  end
end
