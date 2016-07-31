class Merge

  attr_accessor :son_id, :father_id

  def initialize(son_id, father_id)
    self.son_id = son_id
    self.father_id = father_id
  end

  def merge
    local_son = Contact.find_by_padma_id(son_id)
    local_father = Contact.find_by_padma_id(father_id)
    if local_son.present?
      if local_father.nil?
        local_son.update_attribute :padma_id, father_id
      else
        local_son.trial_lessons.update_all(contact_id: local_father.id)

        local_son.attendance_contacts.each do |ac|  
          ac.skip_update_last_seen_at  = true
          ac.contact_id = local_father.id
          if ac.valid?
            ac.save
          else
            ac.destroy
          end
        end

        local_son.contact_time_slots.each do |ct|
          ct.contact_id = local_father.id
          if ct.valid?
            ct.save
          else
            ct.destroy
          end
        end

        local_son.accounts_contacts.each do |ac|
          ac.contact_id = local_father.id
          if ac.valid?
            ac.save
          else
            ac.destroy
          end
        end

        local_father.reload

        # recalculate last_seen_at on father ONCE on each account and in the background using AttendanceContact after_save callback
        local_father.attendance_contacts.joins(:attendance).group('attendances.account_id').each do |ac|
          AttendanceContact.find(ac.id).save
        end

        local_son.destroy
      end
    end
  end
end
