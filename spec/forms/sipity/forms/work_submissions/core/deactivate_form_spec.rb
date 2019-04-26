require "rails_helper"
require 'support/sipity/command_repository_interface'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe DeactivateForm do
          let(:submission_window) { double('Submission Window') }
          let(:work) { double('Work', to_submission_window: submission_window) }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords.merge(attributes: { confirm_deactivate: true })) }

          context 'validation' do
            it 'will require confirmation to deactivate' do
              subject = described_class.new(keywords)
              subject.valid?
              expect(subject.errors[:confirm_deactivate]).to be_present
            end
          end

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:confirm_deactivate, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:legend) { is_expected.to be_html_safe }
          its(:verify_deactivation) { is_expected.to be_html_safe }
          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context '#submit' do
            context 'when invalid' do
              before { allow(subject).to receive(:valid?).and_return(false) }
              it 'will return false' do
                expect(subject.submit).to be_falsey
              end
              it 'will attempt to submit' do
                expect(subject.send(:processing_action_form)).to receive(:submit).and_return(false)
                expect(subject.submit).to be_falsey
              end
            end

            context 'when valid' do
              before { allow(subject).to receive(:valid?).and_return(true) }
              it 'will destroy the object' do
                expect(subject.send(:processing_action_form)).to receive(:submit).and_return(true)
                subject.submit
              end
              it 'will return the associated submission window' do
                expect(subject.send(:processing_action_form)).to receive(:submit).and_return(true)
                expect(subject.submit).to eq(submission_window)
              end
            end
          end
        end
      end
    end
  end
end
