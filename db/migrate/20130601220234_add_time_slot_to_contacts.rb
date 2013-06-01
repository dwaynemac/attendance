class AddTimeSlotToContacts < ActiveRecord::Migration
  def change
    add_reference :contacts, :time_slot, index: true
  end
end
