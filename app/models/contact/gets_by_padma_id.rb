class Contact
  module GetsByPadmaId
    extend ActiveSupport::Concern

    included do

      # Find or create a local contact by given padma_contact_id
      # @param  padma_contact_id [String] ID of contact @ contacts-ws
      # @param  account_id [Integer]
      # @param  padma_contact [PadmaContact] (nil)
      # @param new_contact_attributes [Hash] (nil)
      # @param resync [Boolean]
      # @return [Contact]
      def self.get_by_padma_id(padma_contact_id,account_id,padma_contact=nil,new_contact_attributes=nil, resync=nil)
        return if padma_contact_id.blank?

        #
        # TODO evitar que se duplique chequeando el crm_padma_id del padma_contact
        #
        # situaciones:
        #   padma_contact_id en un crm-id
        #   padma-contact-id es un padma_id
        #     si no encuentro el contacto
        #       lo busco en crm
        #       y busco x su crm-id
        #
        #
        #
        #
        #

        account = Account.find(account_id)
        if (contact = Contact.find_by_padma_id(padma_contact_id))
          #Local Contact found, associate to account if necessary
          unless contact.accounts.include?(account)
            # Get PadmaContact unless it is already present
            if padma_contact.blank?
              padma_contact = CrmLegacyContact.find(padma_contact_id,
                select: [:first_name, :last_name, :local_status],
                username: account.usernames.try(:first),
                account_name: account.name)
            end

            if padma_contact.present?
              contact.accounts_contacts.create(account_id: account.id,
                padma_status: padma_contact.local_status)
            end
          end

          if resync
            contact.sync_from_contacts_ws(padma_contact)
          end
        else
          #Local Contact not found, create & associate to account

          # Get PadmaContact unless it is already present
          if padma_contact.blank?
            padma_contact = CrmLegacyContact.find(padma_contact_id,
              select: [:first_name, :last_name, :local_status],
              username: account.usernames.try(:first),
              account_name: account.name)
          end
          if padma_contact
            #New contact attributes from PadmaContacts
            args = {
              padma_id: padma_contact_id,
              name: "#{padma_contact.first_name} #{padma_contact.last_name}"
            }

            # Merge with local attributes if they are present
            args = args.merge(new_contact_attributes) if new_contact_attributes.present?

            # Create new local Contact
            contact = Contact.create!(args)

            # Associate to account
            contact.accounts_contacts.create(:account => account, :padma_status => padma_contact.local_status) if padma_contact.present?
          end
        end
        contact
      end


    end
  end
end
