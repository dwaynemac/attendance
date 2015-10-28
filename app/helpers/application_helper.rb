module ApplicationHelper


  def flash_notice_is_login_message?
    flash.notice.to_s == I18n.t('devise.failure.unauthenticated')
  end

  def link_to_contact_profile(contact)
    link_to contact.name, "#{APP_CONFIG['crm-url']}/contacts/#{contact.padma_id}"
  end

  def generate_secure_doorbell_signature()
      jsonp_secret = 'hosV7LyVnX8r2IOHXUGmSFqvBWuyYXilLgg94aN17pfqeQ50ob5kCcuUHguUaN4H'
      timestamp = Time.now.to_i
      token = SecureRandom.hex(50)

      signature = OpenSSL::HMAC.hexdigest(
                  OpenSSL::Digest::Digest.new('sha256'),
                  jsonp_secret,
                  '%s%s' % [timestamp, token])

      return "timestamp: #{timestamp}, token: '#{token}', signature: '#{signature}', ".html_safe
  end

  def breadcrum(text)
    content_for :breadcrum, text
  end
end
