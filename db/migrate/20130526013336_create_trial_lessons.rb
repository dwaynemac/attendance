class CreateTrialLessons < ActiveRecord::Migration
  def change
    create_table :trial_lessons do |t|
      t.references :account, index: true
      t.references :contact, index: true
      t.references :time_slot, index: true
      t.date :trial_on
      t.string :padma_uid

      t.timestamps
    end
  end
end
