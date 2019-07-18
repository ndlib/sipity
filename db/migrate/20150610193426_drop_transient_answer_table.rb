class DropTransientAnswerTable < ActiveRecord::Migration[4.2]
  def change
    drop_table 'sipity_transient_answers'
  end
end
