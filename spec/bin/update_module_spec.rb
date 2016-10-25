require 'spec_helper'

def at_exit(*, &_block)
  # I need to avoid the script to run at exit, so I redefine at_exit before it
  # is used by the module.
end

require 'puppetfiles/bin/update_module'

describe Puppetfiles::Bin::UpdateModule do
  let(:puppetfile) { Tempfile.new('Puppetfile.update') }
  let(:mod1) { { name: 'mod1', version: '1.0.0', options: {} } }
  let(:mod2) do
    { name: 'mod2',
      version: '',
      options: { git: 'git@github.com:user/repo.git', ref: '1.0.0' } }
  end
  let(:value) { 'whatever' }

  before(:example) do
    ::Puppetfiles.dump_all([{ path: puppetfile.path, modules: [mod1, mod2] }])
  end
  after(:example) { puppetfile.close! }

  context 'when run without enough arguments' do
    it 'should exit with status 2' do
      [[], [mod1[:name]], [mod1[:name], puppetfile.path]].each do |argv|
        script = ::Puppetfiles::Bin::UpdateModule.new(['--quiet'] + argv)
        expect { script.run }.to raise_error(SystemExit) { |e| e.status == 2 }
      end
    end
  end
  context 'when run without --set options' do
    let(:script) do
      argv = ['--quiet', mod1[:name], puppetfile.path]
      ::Puppetfiles::Bin::UpdateModule.new(argv)
    end
    it 'should exit with status 2' do
      expect { script.run }.to raise_error(SystemExit) { |e| e.status == 2 }
    end
  end
  context 'when run --set-version' do
    let(:script) do
      argv = ['--quiet', '--set-version', value, mod1[:name], puppetfile.path]
      ::Puppetfiles::Bin::UpdateModule.new(argv)
    end
    it 'should update module version' do
      expect { script.run }.to raise_error(SystemExit) { |e| e.status == 0 }
      loaded = ::Puppetfiles.load(puppetfile.path)
      found = loaded.find { |m| m[:name] == mod1[:name] }
      expect(found).to be_truthy
      expect(found[:version]).to eq(value)
    end
  end
  [:git, :ref, :path, :github_tarball].each do |name|
    set = "--set-option-#{name.to_s.tr('_', '-')}"
    context "when run with #{set}" do
      let(:script) do
        argv = ['--quiet', set, value, mod2[:name], puppetfile.path]
        ::Puppetfiles::Bin::UpdateModule.new(argv)
      end
      it "should update module option `:#{name}`" do
        expect { script.run }.to raise_error(SystemExit) { |e| e.status == 0 }
        loaded = ::Puppetfiles.load(puppetfile.path)
        found = loaded.find { |m| m[:name] == mod2[:name] }
        expect(found).to be_truthy
        expect(found[:options][name]).to eq(value)
      end
    end
  end
end
