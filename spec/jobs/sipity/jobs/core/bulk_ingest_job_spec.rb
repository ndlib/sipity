require "rails_helper"
require 'sipity/jobs/core/bulk_ingest_job'
require 'sipity/models/work'
require 'sipity/exceptions'

RSpec.describe Sipity::Jobs::Core::BulkIngestJob do
  let(:work_area_slug) { 'etd' }
  let(:initial_processing_state_name) { 'ready_for_ingest' }
  let(:processing_action_name) { 'submit_for_ingest' }
  let(:repository) { Sipity::QueryRepositoryInterface.new }
  let(:work_ingester) { double('Work Ingester', call: true) }
  let(:exception_handler) { double('Exception Handler', call: true) }

  subject do
    described_class.new(
      work_area_slug: work_area_slug,
      initial_processing_state_name: initial_processing_state_name,
      processing_action_name: processing_action_name,
      repository: repository,
      work_ingester: work_ingester,
      exception_handler: exception_handler
    )
  end

  its(:default_work_ingester) { should respond_to(:call) }
  its(:default_requested_by) { should be_a(String) }
  its(:default_search_criteria_builder) { should respond_to(:call) }
  its(:default_repository) { should respond_to(:find_works_via_search) }
  its(:default_exception_handler) { should respond_to(:call) }

  before { allow(Sipity::Models::Group).to receive(:find_by!).and_return('ETD Ingestor') }

  it 'exposes .call as a convenience method' do
    expect_any_instance_of(described_class).to receive(:call)
    described_class.call(work_area_slug: work_area_slug, initial_processing_state_name: initial_processing_state_name,
    processing_action_name: processing_action_name, repository: repository)
  end

  context '.call' do
    it 'will find all entities for the given work area in the requested state' do
      work = Sipity::Models::Work.new(id: 1)
      expect(repository).to receive(:find_works_via_search).and_return([work])
      subject.call
      expect(work_ingester).to have_received(:call).with(
        work_id: work.id, requested_by: subject.send(:requested_by), processing_action_name: subject.send(:processing_action_name),
        attributes: subject.send(:ingester_attributes)
      )
    end
  end

  context 'with a custom exception handler' do
    it 'will handle exceptions through the exception handler and keep on chugging' do
      work1 = Sipity::Models::Work.new(id: 1)
      work2 = Sipity::Models::Work.new(id: 2)
      allow(repository).to receive(:find_works_via_search).and_return([work1, work2])
      allow(work1).to receive(:reload)
      expect(work_ingester).to receive(:call).with(
        work_id: work1.id, requested_by: subject.send(:requested_by), processing_action_name: subject.send(:processing_action_name),
        attributes: subject.send(:ingester_attributes)
      ).and_raise(RuntimeError, "Failed for work1")
      expect(work_ingester).to receive(:call).with(
        work_id: work2.id, requested_by: subject.send(:requested_by), processing_action_name: subject.send(:processing_action_name),
        attributes: subject.send(:ingester_attributes)
      )
      subject.call
      expect(exception_handler).to have_received(:call).with(
        kind_of(RuntimeError),
        extra: { parameters: { work_id: work1.id,
                               requested_by: subject.send(:requested_by),
                               processing_action_name: subject.send(:processing_action_name),
                               job_class: described_class,
                               work_ingester: work_ingester,
                               attributes: subject.send(:ingester_attributes) } }
      )
      expect(exception_handler).to have_received(:call).with(
        kind_of(Sipity::Exceptions::ScheduledJobError),
        extra: {
          parameters: {
            processing_action_name: subject.send(:processing_action_name),
            job_class: described_class,
            initial_processing_state_name: subject.send(:initial_processing_state_name) } })
    end
  end
end
