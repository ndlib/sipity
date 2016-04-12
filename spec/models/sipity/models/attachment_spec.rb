require 'rails_helper'
require 'sipity/models/attachment'

module Sipity
  module Models
    RSpec.describe Attachment, type: :model do
      context 'class methods' do
        subject { described_class }

        its(:column_names) { is_expected.to include('work_id') }
        its(:column_names) { is_expected.to include('pid') }
        its(:column_names) { is_expected.to include('predicate_name') }
        its(:column_names) { is_expected.to include('file_uid') }
        its(:column_names) { is_expected.to include('file_name') }
        its(:primary_key) { is_expected.to eq('pid') }
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

        context '#thumbnail_url' do
          it "will link to an image's thumbnail" do
            subject.file = File.new(__FILE__)
            expect(subject.file).to receive(:image?).and_return(true)
            expect(subject.thumbnail_url).to match(%r{/#{File.basename(__FILE__)}})
          end

          it "will link to a non-image thumbnail" do
            subject.file = File.new(__FILE__)
            expect(subject.file).to receive(:image?).and_return(false)
            expect(subject.thumbnail_url).to match(%r{/extname_thumbnails/64/64/rb\.png\Z})
          end
        end

        context '#to_rof_file_basename' do
          subject { described_class.new(pid: 'abc:123', file: File.new(__FILE__)).to_rof_file_basename }
          it { is_expected.to be_a(String) }
        end

        it 'will have a file_url that is an actual URL (not a path)' do
          subject = described_class.create!(work_id: 1, pid: 2, file: File.new(__FILE__), predicate_name: 'attachment')
          expect(subject.file_url).to match(%r{https?://[^/]+/attachments})
        end

        it 'will have a file_path that is an absoulte path where file is located' do
          subject = described_class.create!(work_id: 1, pid: 2, file: File.new(__FILE__), predicate_name: 'attachment')
          expect(subject.file_path).to eql(File.expand_path(__FILE__))
        end

        it 'has an file_name via the dragonfly gem' do
          subject.file = File.new(__FILE__)
          expect(subject.file_name).to eq(File.basename(__FILE__))
        end
      end
    end
  end
end
