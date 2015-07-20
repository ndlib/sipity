require 'spec_helper'

module Sipity
  module Forms
    module WorkSubmissions
      module Etd
        RSpec.describe CatalogingCompleteForm do
          let(:work) { Models::Work.new(id: '1234', title: 'Title 1') }
          let(:repository) { CommandRepositoryInterface.new }
          let(:user) { double('User') }
          let(:keywords) { { work: work, repository: repository, requested_by: user, attributes: {} } }
          let(:oclc_number) { ["123456789"] }
          subject { described_class.new(keywords.merge(attributes: { agree_to_signoff: true, oclc_number: oclc_number })) }

          context 'validation' do
            it 'will require agreement to the signoff' do
              subject = described_class.new(keywords.merge(attributes: { oclc_number: oclc_number }))
              subject.valid?
              expect(subject.errors[:agree_to_signoff]).to be_present
            end
          end

          context '#render' do
            it 'will render HTML safe submission terms and confirmation' do
              form_object = double('Form Object')
              expect(form_object).to receive(:input).with(:oclc_number, input_html: { required: "required" }).and_return("<input />")
              expect(form_object).to receive(:input).with(:agree_to_signoff, hash_including(as: :boolean)).and_return("<input />")
              expect(subject.render(f: form_object)).to be_html_safe
            end
          end

          its(:legend) { should be_html_safe }
          its(:signoff_agreement) { should be_html_safe }
          its(:template) { should eq(Forms::STATE_ADVANCING_ACTION_CONFIRMATION_TEMPLATE_NAME) }

          context '#oclc_number' do
            context 'with data from the database' do
              subject { described_class.new(keywords) }
              it 'will return the oclc_number of the work' do
                expect(repository).to receive(:work_attribute_values_for).
                  with(work: work, key: 'oclc_number').and_return(oclc_number)
                expect(subject.oclc_number).to eq oclc_number
              end
            end
          end
          context "submit" do
            subject { described_class.new(keywords.merge(attributes: { agree_to_signoff: true, oclc_number: oclc_number })) }
            before do
              allow(subject).to receive(:valid?).and_return(true)
              allow(subject.send(:processing_action_form)).to receive(:submit).and_yield
            end

            it 'will add additional attributes entries' do
              expect(repository).to receive(:update_work_attribute_values!).and_call_original
              subject.submit
            end
          end
        end
      end
    end
  end
end
