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
    ::Puppetfiles.dump([{ path: puppetfile.path, modules: [mod1, mod2] }])
  end
  after(:example) { puppetfile.close! }

  context 'with `:version` set' do
    let(:script) do
      ::Puppetfiles::Bin::UpdateModule.new(['--set-version',
                                            value,
                                            mod1[:name],
                                            puppetfile.path])
    end
    it 'should update module version' do
      expect { script.run }.to raise_error(SystemExit) { |e| e.status == 0 }
      loaded = ::Puppetfiles.load [puppetfile.path]
      found = loaded.first[:modules].find { |m| m[:name] == mod1[:name] }
      expect(found).to be_truthy
      expect(found[:version]).to eq(value)
    end
  end
  [:git, :ref].each do |name|
    context "with option `:#{name}` set" do
      let(:script) do
        ::Puppetfiles::Bin::UpdateModule.new(["--set-option-#{name}",
                                              value,
                                              mod2[:name],
                                              puppetfile.path])
      end
      it "should update module option `:#{name}`" do
        expect { script.run }.to raise_error(SystemExit) { |e| e.status == 0 }
        loaded = ::Puppetfiles.load [puppetfile.path]
        found = loaded.first[:modules].find { |m| m[:name] == mod2[:name] }
        expect(found).to be_truthy
        expect(found[:options][name]).to eq(value)
      end
    end
  end
end
