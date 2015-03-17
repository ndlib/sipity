require 'spec_helper'

module Sipity
  module Decorators
    RSpec.describe WorkDecorator do
      let(:work) { Models::Work.new(title: 'Hello World', id: 123) }
      let(:repository) { double('Repository') }
      subject { WorkDecorator.new(work, repository: repository) }
      it 'will have a #to_s equal its #title' do
        expect(subject.to_s).to eq(work.title)
      end

      context '#with_form_panel' do
        it 'wrap the results of the block inside a panel' do
          rendered = subject.with_form_panel('attributes') { 'hello' }
          expect(rendered).to have_tag('.panel') do
            with_tag('.panel-heading .panel-title')
            with_tag('.panel-body', text: /hello/)
          end
        end
      end

      context '#rich_text_value' do
        it 'returns the value rendered as HTML' do
          rendered = subject.rich_text_value("several\n\nparagraphs")
          expect(rendered).to have_tag('p', count: 2)
          expect(rendered).to be_html_safe
        end
      end

      it 'shares .object_class with Models::Work' do
        expect(WorkDecorator.object_class).to eq(Models::Work)
      end

      let(:authors) { [double('Author')] }
      it 'will have #authors' do
        expect(repository).to receive(:work_collaborators_for).
          with(work: work, role: 'author').and_return(authors)
        allow(CollaboratorDecorator).to receive(:decorate).with(authors[0])
        subject.authors
      end

      it 'will have a #human_attribute_name' do
        expect(subject.human_attribute_name(:title)).to eq('Title')
      end

      it 'will have #accessible_objects' do
        accessible_objects = [double, double]
        expect(repository).to receive(:access_rights_for_accessible_objects_of).with(work: work).and_return(accessible_objects)
        expect(subject.accessible_objects).to eq(accessible_objects)
      end

      context "#comments" do
        let(:comment) { double(Sipity::Models::Processing::Comment) }
        let(:decorated_comment) { Sipity::Decorators::Processing::ProcessingCommentDecorator.decorate(comment) }
        it 'will have #comments' do
          comments = [comment, comment]
          decorated_comments = [decorated_comment, decorated_comment]

          expect(repository).to receive(:find_comments_for_work).with(work: work).and_return(comments)
          expect(subject.comments).to eq(decorated_comments)
        end
      end

      xit '#state_advancing_actions is missing'
      xit '#resourceful_actions is missing'
      xit '#enrichment_actions is missing'
    end
  end
end
