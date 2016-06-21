require 'spec_helper'
require 'puppetfiles'

include Puppetfiles

describe Puppetfiles do
  describe Puppetfiles::Puppetfiles do
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
        Puppetfiles.loaded << {
          path: 'Puppetfile.spec',
          modules: [] }
      end
      after(:example) do
        Puppetfiles.loaded.clear
      end
      it 'should load a module details' do
        example = {
          name: 'example',
          version: '0.0.0',
          options: {
            git: 'url',
            ref: 'whatever' } }
        Puppetfiles::Mock.mod 'example', '0.0.0',
          :git => 'url',
          :ref => 'whatever'
        expect(Puppetfiles.loaded.last[:modules].last).to eq(example)
      end
    end
    describe '.forge' do
      context 'when a block is given' do
        it 'should yield control' do
          expect { |b| Puppetfiles::Mock.forge('f', &b) }.to yield_control
        end
      end
      context 'when no block is given' do
        it 'should do nothing' do
          expect(Puppetfiles::Mock.forge('f')).to be_nil
        end
      end
    end
    [:metadata, :exclusion].each do |function|
      describe ".#{function}" do
        it 'should do nothing' do
          expect(Puppetfiles::Mock.send function).to be_nil
        end
      end
    end
  end
  [:loaded, :updated, :failures].each do |function|
    describe ".#{function}" do
      it "should return Puppetfiles.instance.#{function}" do
        function_call = Puppetfiles.send function
        method_call = Puppetfiles::Puppetfiles.instance.send function
        expect(function_call).to be(method_call)
      end
    end
  end
  describe '.mod_version' do
    context 'when first argument is not a String' do
      it 'should return an empty String' do
        expect(Puppetfiles.mod_version({a: 1, b: 2})).to eq('')
      end
    end
    context 'when first argument is a String' do
      it 'should return first argument' do
        version = '0.0.0'
        expect(Puppetfiles.mod_version(version, {a: 1, b: 2})).to be(version)
      end
    end
  end
  describe '.mod_options' do
    context 'when last argument is not an Hash' do
      it 'should return an empty Hash' do
        expect(Puppetfiles.mod_options('0.0.0', nil)).to eq({})
      end
    end
    context 'when last argument is an Hash' do
      it 'should return last argument' do
        options = {a: 1, b: 2}
        expect(Puppetfiles.mod_options('0.0.0', options)).to be(options)
      end
    end
  end
  describe '.load' do
  end
  describe '.dump' do
  end
  describe '.add' do
  end
  describe '.remove' do
  end
  describe '.update' do
  end
end
