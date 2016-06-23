require 'spec_helper'
require 'puppetfiles'
require 'tempfile'

describe Puppetfiles do
  # Just to be sure, clear the loaded and updated list after every
  # example
  after(:example) do
    ::Puppetfiles.loaded.clear
    ::Puppetfiles.updated.clear
  end

  let(:version) { '0.0.0' }
  let(:options) { { :git => 'URL', :ref => 'something' } }
  let(:mod1) { { name: 'mod1', version: '1.0.0', options: {} } }
  let(:mod2) do
    { name: 'mod2',
      version: '',
      options: { git: 'git@github.com:user/repo.git', ref: '1.0.0' } }
  end
  let(:mod3) do
    { name: 'mod3',
      version: '',
      options: { git: 'https://github.com/user/repo' } }
  end

  # I could have loaded the module here, but when I did I couldn't remember
  # what I loaded and continuously scrolled up and down to have a look.
  let(:puppetfile1) { { path: 'Puppetfile.first', modules: [] } }
  let(:puppetfile2) { { path: 'Puppetfile.second', modules: [] } }
  let(:puppetfile3) { { path: 'Puppetfile.third', modules: [] } }

  describe Puppetfiles::Puppetfiles do
    # This is a perfect example of unnecessary 'example'. Testing the Singleton
    # implementation is something that should be done by the Ruby team on the
    # 'singleton' module.
    it 'should be a Singleton' do
      expect { Puppetfiles::Puppetfiles.new }.to raise_error(NoMethodError)
      a = Puppetfiles::Puppetfiles.instance
      b = Puppetfiles::Puppetfiles.instance
      expect(b).to be(a)
      expect(ObjectSpace.each_object(Puppetfiles::Puppetfiles).count).to eq(1)
    end
    [:loaded, :updated].each do |attribute|
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
      # The following 3 are good example for unnecessary split: they could
      # have been grouped together.
      it 'should return an Array' do
        expect(mod(mod1[:name], mod1[:version])).to be_an(Array)
      end
      it 'should retrun an Array of Hash-es' do
        expect(mod(mod2[:name],
                   :git => mod2[:options][:git],
                   :ref => mod2[:options][:ref]).last).to be_an(Hash)
      end
      it 'should return the modules details loaded so far' do
        mod(mod1[:name], mod1[:version])
        modules = mod(mod3[:name], :git => mod3[:options][:git])
        expect(modules).to eq([mod1, mod3])
      end
      it "should modify the last loaded Puppetfile's modules list" do
        mod mod1[:name], mod1[:version]
        mod mod2[:name],
          :git => mod2[:options][:git],
          :git => mod2[:options][:ref]
        modules = mod(mod3[:name], :git => mod3[:options][:git])
        expect(::Puppetfiles.loaded.last[:modules]).to eq(modules)
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
  [:loaded, :updated].each do |function|
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
        expect(::Puppetfiles.mod_version(options)).to eq('')
      end
    end
    context 'when first argument is a String' do
      it 'should return first argument' do
        expect(::Puppetfiles.mod_version(version, options)).to be(version)
      end
    end
  end
  describe '.mod_options' do
    context 'when last argument is not an Hash' do
      it 'should return an empty Hash' do
        expect(::Puppetfiles.mod_options(version)).to eq({})
      end
    end
    context 'when last argument is an Hash' do
      it 'should return last argument' do
        expect(::Puppetfiles.mod_options(version, options)).to be(options)
      end
    end
  end
  describe '.load' do
    let(:path) { File.join('spec', 'fixtures', 'Puppetfile.load') }
    it 'should load files without errors' do
      expect { ::Puppetfiles.load([path]) }.not_to raise_error
    end
    it 'should turn a Puppetfile into an Hash and store it into .loaded' do
      ::Puppetfiles.load([path])
      expect(::Puppetfiles.loaded.last).to be_an(Hash)
      expect(::Puppetfiles.loaded.last[:path]).to eq(path)
      expect(::Puppetfiles.loaded.last[:modules].count).to be > 0
    end
  end
  describe '.dump' do
    let(:tmp) { Tempfile.new('Puppetfile.dump') }
    after(:example) { tmp.close! }
    it 'should dump an Hash as a Puppetfile' do
      puppetfiles = [{ path: tmp.path, modules: [mod1, mod2, mod3] }]
      ::Puppetfiles.dump(puppetfiles)
      ::Puppetfiles.load([tmp.path])
      expect(::Puppetfiles.loaded.count).to eq(1)
      expect(::Puppetfiles.loaded.first[:path]).to eq(tmp.path)
      expect(::Puppetfiles.loaded.first[:modules].count).to eq(3)
      expect(::Puppetfiles.loaded.first[:modules].first).to eq(mod1)
      expect(::Puppetfiles.loaded.first[:modules].last).to eq(mod3)
    end
  end
  describe '.save' do
    before(:example) { @tmp = Tempfile.new('Puppetfile.save') }
    after(:example) { @tmp.close! }
    it 'should dump the updated puppet modules' do
      puppetfile = { path: @tmp.path, modules: [mod1, mod2, mod3] }
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
    before(:example) do
      puppetfile1[:modules] << mod3
      puppetfile2[:modules] << mod1
      [puppetfile1, puppetfile2].each {|p| ::Puppetfiles.loaded << p }
    end
    it 'should return the list of modified Puppetfiles (all)' do
      modified = ::Puppetfiles.add(mod2[:name], mod2[:options])
      expect(modified).to eq(::Puppetfiles.loaded)
    end
    it 'should add 1 module to all loaded Puppetfiles' do
      ::Puppetfiles.add(mod2[:name], mod2[:options])
      ::Puppetfiles.loaded.each do |puppetfile|
        expect(puppetfile[:modules].last).to eq(mod2)
      end
    end
    it 'should flag all loaded Puppetfile as updated' do
      modified = ::Puppetfiles.add(mod2[:name], mod2[:options])
      loaded = ::Puppetfiles.loaded
      updated = ::Puppetfiles.updated
      [modified, loaded, updated].each do |result|
        result.sort_by! {|p| p[:path] }
      end
      expect(loaded).to eq(updated)
      expect(loaded).to eq(modified)
    end
  end
  describe '.remove' do
    before(:example) do
      [mod3, mod2].each {|m| puppetfile1[:modules] << m}
      [mod1, mod3].each {|m| puppetfile2[:modules] << m}
      [puppetfile1, puppetfile2].each {|p| ::Puppetfiles.loaded << p }
    end
    it 'should return the list of modified Puppetfiles' do
      expect(::Puppetfiles.remove(mod2[:name])).to eq([puppetfile1])
    end
    it 'should flag the modified Puppetfiles as updated' do
      matching = [puppetfile1]
      updated = ::Puppetfiles.remove(mod2[:name])
      expect(updated.count).to eq(1)
      expect(updated).to eq(matching)
      expect(updated.first[:path]).to eq(matching.first[:path])
      updated.each do |puppetfile|
        expect(::Puppetfiles.updated.include?(puppetfile)).to be_truthy
      end
    end
    it 'should remove the module from all Puppetfiles (declaring it)' do
      ::Puppetfiles.remove(mod1[:name])
      ::Puppetfiles.loaded.each do |puppetfile|
        found = puppetfile[:modules].find {|m| m[:name] == mod1[:name]}
        expect(found).to be_falsy
      end
    end
  end
  describe '.update' do
    before(:example) do
      [mod2.dup, mod1.dup].each {|m| puppetfile1[:modules] << m}
      [mod1.dup, mod3.dup].each {|m| puppetfile2[:modules] << m}
      [puppetfile1, puppetfile2].each {|p| ::Puppetfiles.loaded << p }
    end
    it 'should return the list of updated Puppetfiles' do
      modified = ::Puppetfiles.update(mod2[:name], :ref => '1.0.1')
      expect(modified.count).to eq(1)
      expect(modified.first[:path]).to eq(puppetfile1[:path])
    end
    it 'should flag the modified Puppetfiles as updated' do
      matching = [puppetfile1]
      updated = ::Puppetfiles.update(mod2[:name], :ref => '1.0.1')
      expect(updated).to eq(matching)
      expect(updated.first[:path]).to eq(puppetfile1[:path])
      expect(::Puppetfiles.updated.include?(puppetfile1)).to be_truthy
    end
    it 'should update the module in any Puppetfiles (decalring it)' do
      ::Puppetfiles.update(mod2[:name], :ref => '1.0.1')
      found = puppetfile2[:modules].find {|m| m[:name] == mod2[:name]}
      expect(found).to be_falsy
      found = puppetfile1[:modules].find {|m| m[:name] == mod2[:name]}
      expect(found).to be_truthy
      expect(found[:options][:ref]).to eq('1.0.1')
    end
  end
end
