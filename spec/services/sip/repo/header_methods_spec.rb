require 'rails_helper'

module Sip
  module Repo
    RSpec.describe HeaderMethods, type: :repository do
      let!(:repository_class) do
        class TestRepository
          include HeaderMethods
        end
      end
      subject { repository_class.new }
      after { Sip::Repo.send(:remove_const, :TestRepository) }

      context '#headers_that_can_be_seen_by_user' do
        it 'will include headers that were created by the user'
        it 'will NOT include headers created by another user'
      end

      context '#assign_a_pid' do
        it 'will assign a unique permanent persisted identifier for the header'
      end

      context '#find_header' do
        it 'raises an exception if nothing is found' do
          expect { subject.find_header('8675309') }.to raise_error
        end
        it 'returns the Header when the object is found' do
          allow(Header).to receive(:find).with('8675309').and_return(:found)
          expect(subject.find_header('8675309')).to eq(:found)
        end
      end

      context '#submit_create_header_form' do
        let(:form) do
          subject.build_create_header_form(
            attributes: {
              title: 'This is my title',
              work_publication_strategy: 'do_not_know',
              publication_date: '2014-11-12',
              collaborators_attributes: {
                "0" => { name: "The person", role: Collaborator::DEFAULT_ROLE }
              }
            }
          )
        end
        context 'with invalid data' do
          it 'will not create a a header' do
            allow(form).to receive(:valid?).and_return(false)
            expect { subject.submit_create_header_form(form) }.
              to_not change { Header.count }
          end
          it 'will return false' do
            allow(form).to receive(:valid?).and_return(false)
            expect(subject.submit_create_header_form(form)).to eq(false)
          end
        end
        context 'with valid data' do
          it 'will create the header with the given attributes' do
            allow(form).to receive(:valid?).and_return(true)
            expect { subject.submit_create_header_form(form) }.to(
              change { Header.count }.by(1) &&
              change { header.additional_attributes.count }.by(1) &&
              change { Collaborator.count }.by(1)
            )
          end
          it 'will grant the user "creator" permission to the work'
          it 'will return the header with the given attributes' do
            form = subject.build_create_header_form(attributes: { title: 'This is my title' })
            allow(form).to receive(:valid?).and_return(true)
            expect(subject.submit_create_header_form(form)).to be_a(Header)
          end
        end
      end

      context '#build_create_header_form' do
        it 'will build an object that can be submitted' do
          expect(subject.build_create_header_form).to respond_to(:submit)
        end
      end

      context '#build_edit_header_form' do
        let(:header) { Header.new(title: 'Hello World', id: '123') }
        it 'will raise an exception if the header is not persisted' do
          allow(header).to receive(:persisted?).and_return(false)
          expect { subject.build_edit_header_form(header: header) }.
            to raise_error(RuntimeError)
        end
        context 'with a persisted object will return an object that' do
          before { allow(header).to receive(:persisted?).and_return(true) }
          subject { repository_class.new.build_edit_header_form(header: header) }
          it { should respond_to :submit }
          it 'will expose an attribute of the underlying header' do
            expect(subject.title).to eq(header.title)
          end
          it 'will expose an additional attribute' do
            AdditionalAttribute.create!(header: header, key: 'chicken', value: 'parmasean')
            expect(subject.chicken).to eq('parmasean')
          end
        end
      end

      context '#submit_edit_header_form' do
        let(:header) { Header.create(title: 'My Title', work_publication_strategy: 'do_not_know') }
        let(:form) { subject.build_edit_header_form(header: header, attributes: { title: 'My New Title', chicken: 'dance' }) }
        context 'with invalid data' do
          before do
            allow(header).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(false)
          end
          it 'will return false' do
            expect(subject.submit_edit_header_form(form)).to eq(false)
          end
          it 'will NOT update the header' do
            expect { subject.submit_edit_header_form(form) }.
              to_not change { header.reload.title }
          end
        end
        context 'with valid data' do
          before do
            AdditionalAttribute.create!(header: header, key: 'chicken', value: 'parmasean')
            allow(header).to receive(:persisted?).and_return(true)
            allow(form).to receive(:valid?).and_return(true)
          end
          it 'will return the header' do
            expect(subject.submit_edit_header_form(form)).to eq(header)
          end
          it 'will update the header information' do
            expect { subject.submit_edit_header_form(form) }.
              to change { header.reload.title }.from('My Title').to('My New Title')
          end
          it 'will update additional attributes' do
            expect { subject.submit_edit_header_form(form) }.
              to change { AdditionalAttribute.where(header: header).pluck(:key, :value) }.
              from([['chicken', 'parmasean']]).to([['chicken', 'dance']])
          end
        end
      end
    end
  end
end
