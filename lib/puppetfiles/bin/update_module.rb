require 'sensu-plugin/check/cli'
require 'puppetfiles'

# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
# FIXME: Need to define a Sensu::Plugin::CLI inspired class, specifically
#        designed for MSM ruby scripts.
module Puppetfiles
  module Bin
    # update module
    class UpdateModule < Sensu::Plugin::CLI
      option :version,
             long: '--set-version VERSION',
             description: 'Set module version',
             required: false,
             default: ''

      option :git,
             long: '--set-option-git URL',
             description: 'Set module git repository URL',
             required: false

      option :ref,
             long: '--set-option-ref REF',
             description: 'Set module git ref string',
             required: false

      option :path,
             long: '--set-option-path PATH',
             description: 'Set module git path string',
             required: false

      option :github_tarball,
             long: '--set-option-github-tarball PATH',
             description: 'Set module github_tarball option',
             required: false

      option :quiet,
             long: '--quiet',
             description: 'Suppress output',
             required: false,
             boolean: true

      option :help,
             long: '--help',
             description: 'Show this message',
             on: :tail,
             boolean: true,
             show_options: true,
             exit: 0

      option :print_version,
             long: '--version',
             boolean: true,
             description: 'Print version string',
             required: false

      def output(*args)
        # Just in case we want to be quiet (i.e. specs)
        config[:quiet] || puts("#{self.class.name}: " + args.join(' '))
        nil
      end

      def run
        # Just print version and exit
        ok ::Puppetfiles::VERSION if config[:print_version]

        # Get the mod name and the list of files to update
        mod = argv.first
        files = argv.drop(1)

        critical 'Need a module name' unless mod
        critical 'Need at least 1 Puppetfile to load' if files.empty?

        # Set the details to update
        version = config[:version]
        options = [:git, :ref, :path, :github_tarball]
        options.map! { |o| [o, config[o]] if config[o] }.compact!

        critical 'Need at least one --set option' if options.empty? && !version

        # Load all files and update the mod details
        ::Puppetfiles.load_all files
        ::Puppetfiles.update_all mod, version, options.to_h

        # Get some stats
        loaded = ::Puppetfiles.loaded.count
        updated = ::Puppetfiles.updated.count

        # Save the files
        ::Puppetfiles.save_all

        # Job done
        ok "#{loaded} Puppetfiles loaded, `#{mod}' updated on #{updated}"
      end
    end
  end
end
