require 'spec_helper'
require 'puppetfiles'
require 'tempfile'

describe Puppetfiles do
  # Just to be sure, clear the loaded, updated and failures list after every
  # example
  after(:example) do
    ::Puppetfiles.loaded.clear
    ::Puppetfiles.updated.clear
    ::Puppetfiles.failures.clear
  end
  let(:mod1) { { name: 'mod1', version: '1.0', options: {} } }
  let(:mod2) { {
    name: 'mod2',
    version: '',
    options: { git: 'URL', ref: 'whatever' } } }
  describe Puppetfiles::Puppetfiles do
    # This is a perfect example of unnecessary 'example'. Testing the Singleton
    # implementation is something that should be done by the Ruby team on the
    # 'singleton' module.
    it 'should be a Singleton' do
      expect { Puppetfiles::Puppetfiles.new }.to raise_error(NoMethodError)
      a = Puppetfiles::Puppetfiles.instance
      b = Puppetfiles::Puppetfiles.instance
      expect(b).to be(a)
      expect(ObjectSpace.each_object(Puppetfiles::Puppetfiles){}).to eq(1)
    end
    [:loaded, :updated, :failures].each do |attribute|
      describe ".#{attribute}" do
        instance = Puppetfiles::Puppetfiles.instance
        it 'should return an Array' do
          expect(instance.send attribute).to be_an(Array)
        end
      end
    end
  end
  describe Puppetfiles::Mock do
    describe '.mod' do
      before(:example) do
        ::Puppetfiles.loaded << {
          path: 'Puppetfile.spec',
          modules: [] }
      end
      it 'should load a module details' do
        mod 'mod1', '1.0'
        mod 'mod2',
          :git => 'URL',
          :ref => 'whatever'
        expect(::Puppetfiles.loaded.last[:modules].count).to eq(2)
        expect(::Puppetfiles.loaded.last[:modules].first).to eq(mod1)
        expect(::Puppetfiles.loaded.last[:modules].last).to eq(mod2)
      end
    end
    describe '.forge' do
      context 'when a block is given' do
        it 'should yield control' do
          expect { |b| forge('f', &b) }.to yield_control
        end
      end
      context 'when no block is given' do
        it 'should do nothing' do
          expect(forge('f')).to be_nil
        end
      end
    end
    [:metadata, :exclusion].each do |function|
      describe ".#{function}" do
        it 'should do nothing' do
          expect(send function).to be_nil
        end
      end
    end
  end
  [:loaded, :updated, :failures].each do |function|
    describe ".#{function}" do
      it "should return Puppetfiles.instance.#{function}" do
        function_call = ::Puppetfiles.send function
        method_call = ::Puppetfiles::Puppetfiles.instance.send function
        expect(function_call).to be(method_call)
      end
    end
  end
  describe '.mod_version' do
    context 'when first argument is not a String' do
      it 'should return an empty String' do
        expect(::Puppetfiles.mod_version({a: 1, b: 2})).to eq('')
      end
    end
    context 'when first argument is a String' do
      it 'should return first argument' do
        version = '0.0.0'
        expect(::Puppetfiles.mod_version(version, {a: 1, b: 2})).to be(version)
      end
    end
  end
  describe '.mod_options' do
    context 'when last argument is not an Hash' do
      it 'should return an empty Hash' do
        expect(::Puppetfiles.mod_options('0.0.0', nil)).to eq({})
      end
    end
    context 'when last argument is an Hash' do
      it 'should return last argument' do
        options = {a: 1, b: 2}
        expect(::Puppetfiles.mod_options('0.0.0', options)).to be(options)
      end
    end
  end
  describe '.load' do
    let(:path) { File.join('spec', 'fixtures', 'Puppetfile.load') }
    it 'should properly load files' do
      expect { ::Puppetfiles.load([path]) }.not_to raise_error
      expect(::Puppetfiles.loaded.last[:path]).to eq(path)
      expect(::Puppetfiles.loaded.last[:modules].count).to be > 0
    end
  end
  describe '.dump' do
    before(:example) { @tmp = Tempfile.new('Puppetfile.dump') }
    after(:example) { @tmp.close! }
    it 'should dump a list puppet modules details' do
      ::Puppetfiles.dump([{ path: @tmp.path, modules: [mod1, mod2] }])
      ::Puppetfiles.load([@tmp.path])
      expect(::Puppetfiles.loaded.count).to eq(1)
      expect(::Puppetfiles.loaded.first[:path]).to eq(@tmp.path)
      expect(::Puppetfiles.loaded.first[:modules].count).to eq(2)
      expect(::Puppetfiles.loaded.first[:modules].first).to eq(mod1)
      expect(::Puppetfiles.loaded.first[:modules].last).to eq(mod2)
    end
  end
  describe '.save' do
    before(:example) { @tmp = Tempfile.new('Puppetfile.save') }
    after(:example) { @tmp.close! }
    it 'should dump the updated puppet modules' do
      puppetfile = { path: @tmp.path, modules: [mod1, mod2] }
      ::Puppetfiles.updated << puppetfile
      ::Puppetfiles.save
      expect(File.read(@tmp.path).size).to be > 0
      expect { ::Puppetfiles.load([@tmp.path]) }.not_to raise_error
      expect(::Puppetfiles.updated).to be_empty
      expect(::Puppetfiles.loaded.count).to eq(1)
      expect(::Puppetfiles.loaded.first).to eq(puppetfile)
    end
  end
  describe '.add' do
    let(:first) { { path: 'Puppetfile.first', modules: [] } }
    let(:last) { { path: 'Puppetfile.last', modules: [] } }
    it 'should add a module to all loaded Puppetfiles' do
      ::Puppetfiles.loaded << first
      ::Puppetfiles.loaded << last
      ::Puppetfiles.add(mod1[:name], mod1[:version])
      ::Puppetfiles.add(mod2[:name], mod2[:options])

      expect(::Puppetfiles.loaded).to eq(::Puppetfiles.updated)
      expect(::Puppetfiles.updated.first[:modules].count).to eq(2)
      expect(::Puppetfiles.updated.first[:modules]).to eq([mod1, mod2])
      first_modules = ::Puppetfiles.updated.first[:modules]
      last_modules = ::Puppetfiles.updated.last[:modules]
      expect(first_modules).to eq(last_modules)
    end
  end
  describe '.remove' do
  end
  describe '.update' do
  end
end
