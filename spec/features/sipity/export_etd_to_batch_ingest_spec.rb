require 'rails_helper'

feature 'Export ETD to Batch Ingest' do
  before do
    path = Rails.root.join('app/data_generators/sipity/data_generators/work_areas/etd_work_area.config.json')
    Sipity::DataGenerators::WorkAreaGenerator.call(path: path)
  end
  let(:user) { Sipity::Factories.create_user }
  let(:submission_window) { Sipity::Models::SubmissionWindow.find_by!(slug: 'start') }
  let(:repository) { Sipity::CommandRepository.new }

  it 'will export an ROF file with JSON metadata, a webhook, and any attachments to the mount path' do
    work = repository.create_work!(
      submission_window: submission_window, title: 'My Work', work_type: Sipity::Models::WorkType::MASTER_THESIS
    )
    repository.grant_creating_user_permission_for!(entity: work, user: user)
    Sipity::Jobs::Etd::PerformActionForWorkJob.call(
      work_id: work.id, requested_by: user, processing_action_name: 'describe', attributes: { abstract: 'My Abstract' }
    )

    Sipity::Exporters::EtdExporter.call(work)
  end

end
