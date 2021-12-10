require "rails_helper"
require 'support/sipity/command_repository_interface'

module Sipity
  module Forms
    module WorkSubmissions
      module Core
        RSpec.describe ReingestFileForm do
          let(:work) { Models::Work.new(id: '1234') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:attributes) { {} }
          let(:keywords) { { work: work, repository: repository, requested_by: double, attributes: attributes } }
          subject { described_class.new(keywords) }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords.merge(attributes: { confirm_reingest: true })) }

          context 'validation' do
            it 'will require confirmation to reingest' do
              subject = described_class.new(keywords)
              subject.valid?
              expect(subject.errors[:confirm_reingest]).to be_present
            end
          end

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:confirm_reingest, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:legend) { is_expected.to be_html_safe }
          its(:verify_reingest) { is_expected.to be_html_safe }
          its(:template) { is_expected.to eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context '#submit' do
            context 'when invalid' do
              before { allow(subject).to receive(:valid?).and_return(false) }
              it 'will return false' do
                expect(subject.submit).to be_falsey
              end
            end

            context 'when valid' do
              let(:subject) { described_class.new(keywords) }
              before do
                allow(subject).to receive(:valid?).and_return(true)
              end
              it { is_expected.to delegate_method(:submit).to(:processing_action_form) }
            end
          end
        end
      end
    end
  end
end
