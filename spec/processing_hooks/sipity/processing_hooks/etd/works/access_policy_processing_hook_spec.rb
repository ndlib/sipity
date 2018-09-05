require 'rails_helper'
require 'sipity/processing_hooks/etd/works/access_policy_processing_hook'
require 'support/sipity/command_repository_interface'
require 'sipity/models/work'

module Sipity
  module ProcessingHooks
    module Etd
      module Works
        RSpec.describe AccessPolicyProcessingHook do
          context '.call' do
            let(:work) { Models::Work.create!(id: '123') }
            let(:repository) { CommandRepositoryInterface.new }
            it 'will force the work record to have an Public access policy' do
              described_class.call(entity: work, repository: repository)
              expect(work.access_right.access_right_code).to eq(Models::AccessRight::OPEN_ACCESS)
            end
          end
        end
      end
    end
  end
end
