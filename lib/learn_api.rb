class LearnApi

  attr_accessor :api_key, :last_response

  def initialize(api_key = ENV["learn_api_key"])
    self.api_key = api_key
  end

  def get(endpoint, params= {})
    self.last_response = Typhoeus.get(
      url(endpoint),
      params: params.merge({api_key: api_key})
    )
    if last_response.code == 200
      ActiveSupport::JSON.decode last_response.body
    else
      nil
    end
  end

  def post(endpoint, params = {})
    self.last_response = Typhoeus.post(
      url(endpoint),
      body: params.merge({api_key: api_key}))
    if last_response.code == 201
      ActiveSupport::JSON.decode last_response.body
    else
      nil
    end
  end

  def put(endpoint, params = {})
    self.last_response = Typhoeus.put(
      url(endpoint),
      params: params.merge({api_key: api_key}))
    if last_response.code == 201
      ActiveSupport::JSON.decode last_response.body
    else
      nil
    end
  end

  def last_response_body
    ActiveSupport::JSON.decode last_response.body
  end

  private

  def url(endpoint = "")
    "#{host}/admin#{endpoint}"
  end

  def host
    if Rails.env.production?
      "https://learn.derose.app"
    else
      "http://localhost:3031"
    end
  end

end
