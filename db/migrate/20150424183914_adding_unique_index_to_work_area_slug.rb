class AddingUniqueIndexToWorkAreaSlug < ActiveRecord::Migration[5.2]
  def change
    add_column 'sipity_work_areas', 'name', 'string'
    add_index 'sipity_work_areas', 'name', unique: true
    add_index 'sipity_work_areas', 'slug', unique: true
    add_index 'sipity_application_concepts', 'slug', unique: true
  end
end
