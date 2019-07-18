require "rails_helper"

module Sipity
  module Queries
    RSpec.describe CommentQueries, type: :isolated_repository_module do
      subject { test_repository }
      context '#find_comments_for' do
        let(:entity) { Models::Processing::Entity.new(id: 1) }
        subject { test_repository.find_comments_for(entity: entity) }
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

      context '#find_current_comments_for' do
        let(:strategy_id) { 1 }
        let(:current_strategy_state_id) { 2 }
        let(:work) { Models::Work.new(id: 'abc') }
        let(:entity) do
          Models::Processing::Entity.create!(
            proxy_for_id: work.id, proxy_for_type: work.class, strategy_id: strategy_id, strategy_state_id: current_strategy_state_id
          )
        end

        let!(:actions) do
          # Creating actions, some of which will be associated with the entity's current_strategy_state
          (1..2).collect do |index|
            Models::Processing::StrategyAction.create(
              strategy_id: strategy_id,
              resulting_strategy_state_id: current_strategy_state_id + (index % 2),
              name: "action_#{index}"
            )
          end
        end

        let!(:comments) do
          # Creating comments for various points along the way; Note we don't care about originating strategy state
          # Just what was the action taken as part of this comment.
          (1..4).collect do |index|
            Models::Processing::Comment.create!(
              originating_strategy_state_id: index, originating_strategy_action_id: actions[(index % actions.size)].id,
              entity_id: entity.id, actor_id: 99, comment: "Comment #{index}",
              stale: (index % 3).zero?
            )
          end
        end

        it 'will find all comments that were written as part of any action that can transition the entity to its current state' do
          # NOTE: the 3rd comment is stale and thus excluded
          expect(test_repository.find_current_comments_for(entity: work).pluck(:comment)).to eq(["Comment 1"])
        end
      end
    end
  end
end
