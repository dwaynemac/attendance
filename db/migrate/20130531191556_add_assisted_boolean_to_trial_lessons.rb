class AddAssistedBooleanToTrialLessons < ActiveRecord::Migration
  def change
    add_column :trial_lessons, :assisted, :boolean
  end
end
