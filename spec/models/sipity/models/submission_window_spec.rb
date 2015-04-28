require 'rails_helper'

module Sipity
  module Models
    RSpec.describe SubmissionWindow, type: :model do
      context 'database configuration' do
        subject { described_class }
        its(:column_names) { should include('work_area_id') }
        its(:column_names) { should include('slug') }
      end

      subject { described_class.new }

      it 'will have many .submission_window_work_types' do
        expect(subject.submission_window_work_types).to be_a(ActiveRecord::Relation)
      end

      it 'will have one .strategy_usage' do
        expect(subject.association(:strategy_usage)).to be_a(ActiveRecord::Associations::HasOneAssociation)
      end

      context '#slug' do
        it 'will transform the slug to a URI safe item' do
          subject.slug = 'Hello World'
          expect(subject.slug).to eq('hello-world')
        end
      end
    end
  end
end
