require 'spec_helper'
require 'sipity/exceptions'
require 'sipity/exceptions'

module Sipity
  module Exceptions
    RSpec.describe InvalidSchemaError do
      subject { described_class.new(errors: { key: 'error' }) }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe FailedToInitializeWorkConverterError do
      subject { described_class.new(work: { key: 'error' }) }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe EmailAsOptionInvalidError do
      subject { described_class.new(as: :chicken, valid_list: [:hello]) }
      its(:message) { is_expected.to be_a(String) }
    end
    RSpec.describe ResponseHandlerError do
      subject { described_class.new(object: double, errors: [], status: :failure) }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe ExistingMethodsAlreadyDefined do
      subject { described_class.new('hello', [:ab, :cd]) }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe ConversionError do
      subject { described_class.new('hello') }
      its(:message) { is_expected.to be_a(String) }
      its(:conversion_target) { is_expected.to be_a(String) }
    end

    RSpec.describe UnprocessableResourcefulActionNameError do
      subject { described_class.new(container: 'Container', object: 'hello') }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe AuthenticationFailureError do
      subject { described_class.new('hello') }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe UnhandledResponseError do
      subject { described_class.new('hello') }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe InterfaceExpectationError do
      subject { described_class.new(object: 'hello', expectations: :fly) }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe InterfaceCollaboratorExpectationError do
      subject { described_class.new(object: 'hello', collaborator_expectations: { fly: :guy }) }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe AuthorizationFailureError do
      let(:user) { double }
      let(:action) { double }
      let(:entity) { double }
      subject { described_class.new(user: user, action_to_authorize: action, entity: entity) }
      its(:message) { is_expected.to be_a(String) }
      its(:user) { is_expected.to eq(user) }
      its(:action_to_authorize) { is_expected.to eq(action) }
      its(:entity) { is_expected.to eq(entity) }
    end

    RSpec.describe ConceptNotFoundError do
      subject { described_class.new(container: 'hello', name: 'world') }
      its(:message) { is_expected.to be_a(String) }
    end

    RSpec.describe InvalidStateError do
      let(:entity) { '"Entity"' }
      let(:actual) { '"actual"' }
      context 'without an expected state' do
        let(:expected) { nil }
        subject { described_class.new(entity: entity, actual: actual, expected: expected) }
        its(:entity) { is_expected.to eq(entity) }
        its(:actual) { is_expected.to eq(actual) }
        its(:expected) { is_expected.to eq(expected) }
        its(:message) { is_expected.to be_a(String) }
      end

      context 'with an expected state' do
        let(:expected) { '"expected"' }
        subject { described_class.new(entity: entity, actual: actual, expected: expected) }
        its(:entity) { is_expected.to eq(entity) }
        its(:actual) { is_expected.to eq(actual) }
        its(:message) { is_expected.to be_a(String) }
      end
    end

    RSpec.describe SenderNotFoundError do
      subject { described_class.new('hello') }
      its(:message) { is_expected.to be_a(String) }
    end
  end
end
