require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context ':rof_hash' do
    it "will convert a Sipity::Models::Attachment" do
      object = Sipity::Models::Attachment.new
      expect(Sipity::Conversions::ToRofHash::AttachmentConverter).to receive(:call).with(attachment: object).and_return(:converted)
      PowerConverter.convert(object, to: :rof_hash)
    end
    it "will convert a Sipity::Models::Work" do
      object = Sipity::Models::Work.new
      expect(Sipity::Conversions::ToRofHash::WorkConverter).to receive(:call).with(work: object).and_return(:converted)
      PowerConverter.convert(object, to: :rof_hash)
    end
    it "will not convert a Sipity::Models::Processing::Entity" do
      object = Sipity::Models::Processing::Entity.new
      expect { PowerConverter.convert(object, to: :rof_hash) }.to raise_error(PowerConverter::ConversionError)
    end
  end
end
