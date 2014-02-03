class CreateContactTimeSlots < ActiveRecord::Migration
  def change
    create_table :contact_time_slots do |t|
      t.references :contact
      t.references :time_slot
      t.timestamps
    end
    Contact.all.each do |contact|
      unless contact.time_slot_id.nil?
        ContactTimeSlot.create(contact_id: contact.id, time_slot_id: contact.time_slot_id)
      end
    end
  end
end
