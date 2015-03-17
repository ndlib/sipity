module Sipity
  module Queries
    RSpec.describe CommentQueries, type: :isolated_repository_module do
      subject { test_repository }
      context '#find_comments_for_work' do
        let(:entity) { Models::Processing::Entity.new(id: 1) }
        subject { test_repository.find_comments_for_work(work: entity) }
        it 'will return comments for that work' do
          comment = Models::Processing::Comment.create!(
            entity_id: entity.id,
            comment: 'Comment 1',
            actor_id: "1",
            originating_strategy_action_id: "10",
            originating_strategy_state_id: '100'
          )
          expect(subject).to eq([comment])
        end
      end
    end
  end
end
