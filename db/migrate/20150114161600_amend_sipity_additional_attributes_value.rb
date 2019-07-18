class AmendSipityAdditionalAttributesValue < ActiveRecord::Migration[4.2]
  def change
    change_column :sipity_additional_attributes, :value, :text
  end
end
