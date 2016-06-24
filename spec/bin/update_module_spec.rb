require 'spec_helper'
require 'puppetfiles/bin/update_module'

class UpdateModule
  include Puppetfiles::Bin::UpdateModule
  attr_accessor :config, :argv, :status, :output
  def initialize(argv, config)
    @argv = argv
    @config = config
    @output = ''
  end

  def output(msg = nil)
    return @output unless msg
    @output << msg
    nil
  end

  { ok: 0, warning: 1, critical: 2, unknown: 3 }.each do |name, code|
    define_method(name) do |*args|
      @status = code
      output(*args)
      exit(code)
    end
  end
end

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
      UpdateModule.new([mod1[:name], puppetfile.path], version: value)
    end
    it 'should update module version' do
      expect { script.main }.to raise_error(SystemExit)
      expect(script.status).to eq(0)
      loaded = ::Puppetfiles.load [puppetfile.path]
      found = loaded.first[:modules].find { |m| m[:name] == mod1[:name] }
      expect(found).to be_truthy
      expect(found[:version]).to eq(value)
    end
  end
  [:git, :ref].each do |name|
    context "with option `:#{name}` set" do
      let(:script) do
        UpdateModule.new([mod2[:name], puppetfile.path], name => value)
      end
      it "should update module option `:#{name}`" do
        expect { script.main }.to raise_error(SystemExit)
        expect(script.status).to eq(0)
        loaded = ::Puppetfiles.load [puppetfile.path]
        found = loaded.first[:modules].find { |m| m[:name] == mod2[:name] }
        expect(found).to be_truthy
        expect(found[:options][name]).to eq(value)
      end
    end
  end
end
