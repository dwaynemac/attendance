class PadmaCrmApi

  def self.update_contact(padma_id, attributes = {}, options = {})
    params = {
      app_key: ENV["crm_contacts_v0_api_key"]
    }
    body = {
    }
    if options[:account_name]
      params[:account_name] = options.delete(:account_name)
    end
    params[:contact] = attributes
    res = Typhoeus.put("#{crm_url}/contacts_api/v0/contacts/#{padma_id}", body: body, params: params)
    if res.code == 200
      ActiveSupport::JSON.decode res.body
    end
  end

  def self.crm_url
    if Rails.env.development?
      "http://localhost:3000"
    else
      "https://crm.padm.am"
    end
  end

end