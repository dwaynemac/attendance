class FetchCrmContactJob

  def initialize(attributes = {})
    @attributes = attributes
  end

  def perform
    Contact.get_by_padma_id(@attributes[:id], account.id)
  end

  private

  def padma_contact
    @padma_contact ||= CrmLegacyContact.find @attributes[:id], account_name: @attributes[:account_name]
  end

  def account
    if @attributes[:account_name]
      @account ||= Account.find_by_name @attributes[:account_name]
    end
  end

end
