require "rails_helper"
require 'sipity/services/administrative/update_who_submitted_work'

module Sipity
  RSpec.describe Services::Administrative::UpdateWhoSubmittedWork do

    before do
      path = Rails.root.join('app/data_generators/sipity/data_generators/work_areas/etd_work_area.config.json')
      Sipity::DataGenerators::WorkAreaGenerator.call(path: path)
    end
    let(:from_username) { "from-person" }
    let(:to_username) { "to-person" }
    let(:from_user) { User.create!(username: from_username) }
    let(:logger) { double("Logger", info: true, warn: true, error: true) }
    let(:repository) { Sipity::CommandRepository.new }
    let(:attributes) { { title: "Hello World", work_type: "doctoral_dissertation", work_publication_strategy: "do_not_know", work_patent_strategy: "do_not_know", permanent_email: "someone@example.com" } }
    let(:submission_window) { Sipity::Models::SubmissionWindow.last }
    scenario 'User can enrich their submission' do
      form = Sipity::Forms::SubmissionWindows::Etd::StartASubmissionForm.new(
        submission_window: submission_window, repository: repository, attributes: attributes, requested_by: from_user
      )
      # Ensure that the form remains valid
      expect(form).to be_valid

      work = form.submit
      expect(work).to be_persisted # conservative check to see that we saved the work

      updater = Sipity::Services::Administrative::UpdateWhoSubmittedWork.new(work: work.id, from_username: from_username, to_username: to_username, logger: logger)

      # While technically not correct, as the permission could be assigned at the strategy level, this checks for the role.
      expect(repository.scope_actors_associated_with_entity_and_role(entity: work, role: updater.role).where(proxy_for: from_user).any?).to eq(true)

      # This builds on the assumption that the "creating_user" can "show" the given work.
      expect(repository.authorized_for_processing?(user: from_user, entity: work, action: 'show')).to eq(true)

      expect(updater.audit!).to eq(true)
      expect { updater.change_it! }.to change { User.count }.by(1)
      to_user = User.find_by(username: to_username)

      expect(repository.scope_actors_associated_with_entity_and_role(entity: work, role: updater.role).where(proxy_for: from_user).any?).to eq(false)
      expect(repository.authorized_for_processing?(user: from_user, entity: work, action: 'show')).to eq(false)

      expect(repository.scope_actors_associated_with_entity_and_role(entity: work, role: updater.role).where(proxy_for: to_user).any?).to eq(true)
      expect(repository.authorized_for_processing?(user: to_user, entity: work, action: 'show')).to eq(true)


    end
  end
end