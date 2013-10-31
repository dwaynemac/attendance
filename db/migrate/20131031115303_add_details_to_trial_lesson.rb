class AddDetailsToTrialLesson < ActiveRecord::Migration
  def change
    add_column :trial_lessons, :confirmed, :boolean
    add_column :trial_lessons, :archived, :boolean
    add_column :trial_lessons, :absence_reason, :string
  end
end
