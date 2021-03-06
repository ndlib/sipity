require "rails_helper"
require 'sipity/response_handlers/work_area_handler'

module Sipity
  module ResponseHandlers
    module WorkAreaHandler
      RSpec.describe SuccessResponder do
        let(:handler) { double(render: 'rendered', template: 'show', request_format: :html) }
        context '.for_controller' do
          it 'will coordinate the rendering of the template' do
            described_class.for_controller(handler: handler)
            expect(handler).to have_received(:render).with(template: handler.template, format: handler.request_format)
          end
        end
        context '.for_command_line' do
          subject { described_class.for_command_line(handler: handler) }
          it { is_expected.to eq(true) }
        end
      end

      RSpec.describe SubmitFailureResponder do
        let(:handler) { double(render: 'rendered', template: 'show', request_format: :html) }
        context '.for_controller' do
          it 'will coordinate the rendering of the template' do
            described_class.for_controller(handler: handler)
            expect(handler).to have_received(:render).with(
              template: handler.template, status: :unprocessable_entity, format: handler.request_format
            )
          end
        end
        context '.for_command_line' do
          let(:handler) { double(response_object: :obj, response_errors: [], response_status: :one) }
          subject { described_class.for_command_line(handler: handler) }
          it 'should raise Sipity::Exceptions::ResponseHandlerError' do
            expect { subject }.to raise_error(Sipity::Exceptions::ResponseHandlerError)
          end
        end
      end
    end
  end
end
