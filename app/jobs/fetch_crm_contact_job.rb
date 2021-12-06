class FetchCrmContactJob

  # @param attributes
  # @option id padma_id del contacto
  # @option account_name
  def initialize(attributes = {})
    @attributes = attributes
  end

  def perform
    ret = false
    if account
      ret = get_and_resync_for_account(account)
    else
      padma_contact.local_statuses.each do |ls|
        if (a = Account.find_by_name ls["account_name"])
          ret = get_and_resync_for_account(a)
        end
      end
    end
    ret
  end

  private

  def get_and_resync_for_account(a)
    Contact.get_by_padma_id(@attributes[:id], a.id, padma_contact, nil, true)
  end

  def padma_contact
    @padma_contact ||= CrmLegacyContact.find @attributes[:id],
      account_name: @attributes[:account_name],
      select: [:local_statuses]
  end

  def account
    if @attributes[:account_name]
      @account ||= Account.find_by_name @attributes[:account_name]
    end
  end

end
