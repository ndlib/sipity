class UpdatingAuthorNameForWork < ActiveRecord::Migration[4.2]
  def self.up
    work_area = PowerConverter.convert('etd', to: :work_area)
    repository = Sipity::CommandRepository.new
    creating_user = Sipity::Models::Role::CREATING_USER
    Sipity::Models::WorkSubmission.where(work_area: work_area).find_each do |work_submission|
      work = work_submission.work
      next if repository.work_attribute_values_for(work: work, key: 'author_name', cardinality: 1)
      users = repository.scope_users_for_entity_and_roles(entity: work_submission.work, roles: [creating_user])
      repository.update_work_attribute_values!(work: work, key: 'author_name', values: users.map(&:name))
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
