require 'rails_helper'

module Sipity
  module Models
    RSpec.describe Attachment, type: :model do
      context 'class methods' do
        subject { described_class }

        its(:column_names) { should include('work_id') }
        its(:column_names) { should include('pid') }
        its(:column_names) { should include('predicate_name') }
        its(:column_names) { should include('file_uid') }
        its(:column_names) { should include('file_name') }
        its(:primary_key) { should eq('pid') }
      end

      context 'instance methods' do
        subject { described_class.new }
        it 'will have a #to_s equal to the file name' do
          subject.file_name = 'Hello World'
          expect(subject.to_s).to eq('Hello World')
        end
        it 'has an file via the dragonfly gem' do
          subject.file = File.new(__FILE__)
          expect(subject.file.data).to eq(File.read(__FILE__))
        end

        it 'has a thumbnail_url' do
          subject.file = File.new(__FILE__)
          expect(subject.thumbnail_url).to match(/\/#{File.basename(__FILE__)}/)
        end

        it 'has an file_name via the dragonfly gem' do
          subject.file = File.new(__FILE__)
          expect(subject.file_name).to eq(File.basename(__FILE__))
        end
      end
    end
  end
end
