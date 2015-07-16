require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe CatalogingCompleteForm do
          let(:work) { double('Work') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user } }
          subject { described_class.new(keywords.merge(attributes: { agree_to_signoff: true })) }

          context 'validation' do
            it 'will require agreement to the signoff' do
              subject = described_class.new(keywords)
              subject.valid?
              expect(subject.errors[:agree_to_signoff]).to be_present
            end
          end

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:legend) { should be_html_safe }
          its(:signoff_agreement) { should be_html_safe }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          it { should delegate_method(:submit).to(:processing_action_form) }
        end
      end
    end
  end
end
