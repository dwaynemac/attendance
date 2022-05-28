# @option padma_id [String]
# @option account_name [String]
class LastSeenAtJob < ApplicationJob

  def perform
    if contact.update_last_seen_at(account)
      # ok, finish
    else
      # error, retry
      raise "Error updating last_seen_at for #{contact.padma_id} in #{account.name}"
    end
  end

  private

  def contact
    if @attributes[:padma_id]
      @contact ||= Contact.find_by_padma_id(@attributes[:padma_id])
    end
  end

  def account
    if @attributes[:account_name]
      @account ||= Account.find_by_name @attributes[:account_name]
    end
  end

end
