#!ruby
# @author Luca De Vitis <luca.devitis at moneysupermarket.com>
require 'sensu-plugin/check/cli'
require 'puppetfiles/bin/update_module'

# This class implements a CLI to `CheckPuppetfiles`. `Sensu::Plugin::CLI` is a
# pretty handy CLI library.
class PuppetfilesUpdateModule < Sensu::Plugin::CLI
  include Puppetfiles::Bin::UpdateModule

  option :version,
         long: '--set-version VERSION',
         description: 'Set module version',
         required: false,
         default: ''

  option :git,
         long: '--set-option-git URL',
         description: 'Set module git repository URL',
         required: false

  option :git,
         long: '--set-option-ref REF',
         description: 'Set module git ref string',
         required: false

  option :help,
         long: '--help',
         description: 'Show this message',
         on: :tail,
         boolean: true,
         show_options: true,
         exit: 0
  def output(*args)
    puts "#{self.class.name}: " + args.join(' ')
  end
  def run
    main
  end
end
