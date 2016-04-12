require 'spec_helper'
require 'sipity/jobs'

module Sipity
  RSpec.describe Jobs do
    context '.submit' do
      it 'will raise a Name Error if the job does not exist' do
        expect { described_class.submit('i_dont_want_to_work') }.to raise_error(Exceptions::JobNotFoundError)
      end

      it 'will submit the found job' do
        a_job_object = double(call: true)
        allow(described_class).to receive(:find_job_by_name).with('a_job_name').and_return(a_job_object)
        described_class.submit('a_job_name', hello: :world)

        expect(a_job_object).to have_received(:call).with(hello: :world)
      end
    end

    context '.find_job_by_name' do
      it 'will find a "namespaced" job' do
        expect(Sipity::Jobs.find_job_by_name('core/bulk_ingest')).to respond_to(:call)
      end
    end
  end
end
