require 'rails_helper'

RSpec.describe 'PowerConverter' do
  context 'polymorphic_type' do
    [
      [User.new, User],
      [User, User]
    ].each_with_index do |(to_convert, expected), index|
      it "will convert #{to_convert.inspect} to #{expected} (Scenario ##{index}" do
        expect(PowerConverter.convert(to_convert, to: :polymorphic_type)).to eq(expected)
      end
    end

    [
      :User, 'User'
    ].each do |to_convert|
      it "will raise an exception for #{to_convert.inspect}" do
        expect { PowerConverter.convert(to_convert, to: :polymorphic_type) }.to raise_error(PowerConverter::ConversionError)
      end
    end
  end
end
