class PadmaCrmApi

  attr_accessor :last_response

  def initialize(options = {})
  end

  # ENV["crm_v0_api_key"]

  def update_contact(padma_id, attributes = {}, options = {})
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

  def crm_url
    if Rails.env.development?
      "http://localhost:3000"
    else
      "https://crm.padm.am"
    end
  end

  # @param attributes
  # @option username
  # @option account_name
  # @option observations
  # @option commented_at
  # @option contact_id
  #
  # @example
  #   api = PadmaCrmApi.new
  #   api.create_comment(contact_id: "52f2c45e598abe77c70000ec", account_name: "cervino", username: "system", observations: "test", commented_at: Time.zone.now)
  #
  # @return Boolean
  def create_comment(attributes)
    response = Typhoeus.post("#{crm_url}/api/v0/comments",
      body: {
          comment: attributes,
      },
      params: {app_key: ENV["crm_v0_api_key"]},
    )
    self.last_response = response
    response.code == 201
  end

  def update_comment(id, new_attributes)
    res = Typhoeus.put("#{crm_url}/api/v0/comments/#{id}",
      params: {
        comment: new_attributes,
        app_key: ENV["crm_contacts_v0_api_key"]
      }
    )
    self.last_response = res
    res.code == 204
  end

  def destroy_comment(id)
    res = Typhoeus.delete("#{crm_url}/api/v0/comments/#{id}",
      params: {app_key: ENV["crm_contacts_v0_api_key"]}
    )
    self.last_response = res
    res.code == 204
  end

end