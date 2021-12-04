class FetchCrmContactJob

  def initialize(attributes = {})
    @attributes = attributes
  end

  def perform
    Contact.get_by_padma_id(@attributes[:id], account.id, padma_contact, nil, true)
  end

  private

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
