class RemoveReleaseSuspendedCatalogRecord < ActiveRecord::Migration[4.2]
  def self.up
    Sipity::Models::Notification::Email.where(method_name: 'release_suspended_catalog_record').destroy_all
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
