require 'spec_helper'
require 'sipity/conversions/to_rof_hash/attachment_converter'

module Sipity
  RSpec.describe Conversions::ToRofHash::AttachmentConverter do
    let(:attachment) { Sipity::Models::Attachment.new(id: '1234-56') }
    it 'exposes .call as a convenience method' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(attachment)
    end

    context '#call' do
      subject { described_class.new(attachment).call }
      it { is_expected.to be_a(Hash) }
    end
  end
end
