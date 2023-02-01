#require './config/boot'
#require './config/environment'

require 'clockwork'
require 'active_support/time'

module Clockwork
  configure do |config|
    #config[:logger] = Appsignal::Logger.new("clockwork") if ENV["APPSIGNAL_LOG"].present?
    config[:tz] = "America/Buenos_Aires"
    config[:thread] = true
  end
  handler do |job, time|
    puts "running #{job}, at #{time}"
    %x{ #{job} }
  end

  every(10.minutes, "rake synchronize", skip_first_run: true)
end
