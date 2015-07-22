require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe IngestWithPostponedCatalogingForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject do
            described_class.new(
              keywords.merge(
                attributes: {
                  agree_to_signoff: true,
                  scheduled_time: '01-01-2010'
                }
              )
            )
          end

          context 'validation' do
            it 'will require agreement to the signoff' do
              subject = described_class.new(keywords.merge(attributes: { scheduled_time: '01-01-2010' }))
              subject.valid?
              expect(subject.errors[:agree_to_signoff]).to be_present
            end
          end

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
              expect(form_object).to receive(:input).with(:scheduled_time, input_html: { required: "required" }).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:legend) { should be_html_safe }
          its(:signoff_agreement) { should be_html_safe }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context 'with valid data' do
            subject do
              described_class.new(
                keywords.merge(
                  attributes: {
                    agree_to_signoff: true,
                    scheduled_time: 'bogus'
                  }
                )
              )
            end

            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end
            it 'will create administrative scheduled actions entries' do
              expect(repository).to receive(:create_scheduled_action).exactly(1).and_call_original
              subject.submit
            end

            it 'will retreive the administrative scheduled actions from work' do
              expect(repository).to receive(:scheduled_time_from_work).exactly(1).and_call_original
              subject.scheduled_time_from_work
            end
          end
        end
      end
    end
  end
end
