module ApplicationHelper

  def current_account
    @session_current_account || current_user.current_account
  end

  def link_to_contact_profile(contact)
    link_to contact.name, "#{APP_CONFIG['crm-url']}/contacts/#{contact.padma_id}"
  end

  def breadcrum(text)
    content_for :breadcrum, text
  end
end
