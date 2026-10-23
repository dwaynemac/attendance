require 'typhoeus_fix/array_decoder'

class Api::V0::ApiController < ActionController::Base

  protect_from_forgery

  include TyphoeusFix
  before_filter :decode_typhoeus_arrays

  APP_KEY = ENV['app_key']

  def self.valid_app_key?(key)
    key.present? && [APP_KEY, ENV['app_key_next']].include?(key)
  end

  before_filter :require_app_key

  def current_ability
    @current_ability ||= Api::Ability.new(params[:app_key])
  end

  rescue_from CanCan::AccessDenied do |exception|
    render :text => "access denied", :status => 401
  end

  private

  def require_app_key
    unless self.class.valid_app_key?(params[:app_key])
      render :text => "wrong app key", :status => 401
    end
  end

end
