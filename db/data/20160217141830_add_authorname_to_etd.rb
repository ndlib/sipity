class AddAuthornameToEtd < ActiveRecord::Migration[4.2]
  def self.up
    repository = Sipity::CommandRepository.new

    Sipity::Models::Work.where(work_type: ['master_thesis', 'doctoral_dissertation']).find_each do |etd|
      next if etd.additional_attributes.where(key: 'author_name').any?
      user_names = repository.scope_users_for_entity_and_roles(entity: etd, roles: 'creating_user').pluck(:name)
      repository.create_work_attribute_values!(work: etd, key: 'author_name', values: user_names)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
