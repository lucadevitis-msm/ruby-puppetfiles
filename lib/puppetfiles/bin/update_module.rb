require 'sensu-plugin/check/cli'
require 'puppetfiles'

# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
# This class implements a CLI to `CheckPuppetfiles`. `Sensu::Plugin::CLI` is a
# pretty handy CLI library.
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

      option :help,
             long: '--help',
             description: 'Show this message',
             on: :tail,
             boolean: true,
             show_options: true,
             exit: 0

      # Better output
      # FIXME: need to define a MSM script class subclassing Sensu::Plugin::CLI
      def output(*args)
        puts "#{self.class.name}: " + args.join(' ')
      end

      # FIXME: need to find a way override the run method from
      # Sensu::Plugin::CLI
      def run
        mod = argv.first
        files = argv.drop(1)
        version = config[:version]
        keys = [:git, :ref]
        options = keys.map { |k| [k, config[k]] if config[k] }.compact.to_h
        ::Puppetfiles.load files
        ::Puppetfiles.update mod, version, options
        count = ::Puppetfiles.loaded.count
        updated = ::Puppetfiles.loaded.count
        ::Puppetfiles.save
        ok "#{count} Puppetfiles loaded, `#{mod}' updated on #{updated}"
      end
    end
  end
end
