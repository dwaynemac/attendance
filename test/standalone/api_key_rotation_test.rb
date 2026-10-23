# Run without booting Rails or requiring the application's asset dependencies:
# rbenv exec ruby test/standalone/api_key_rotation_test.rb
require 'minitest/autorun'
gem 'actionpack', '4.2.8'
gem 'logical_model', '0.7.1'
require 'action_controller'
require 'cancan'

module Api
  module V0
  end
end

require_relative '../../app/controllers/api/v0/api_controller'
require_relative '../../app/models/api/ability'

class ApiKeyRotationTest < Minitest::Test
  class ProbeController < Api::V0::ApiController
    attr_reader :rendered

    def render(options)
      @rendered = options
    end
  end

  def setup
    @original_key = Api::V0::ApiController::APP_KEY
    @original_next = ENV['app_key_next']
    replace_primary('old-test-key')
    ENV['app_key_next'] = 'new-test-key'
  end

  def teardown
    replace_primary(@original_key)
    ENV['app_key_next'] = @original_next
  end

  def test_primary_key_still_authenticates_and_authorizes_during_overlap
    assert_access('old-test-key', true)
  end

  def test_replacement_key_authenticates_and_authorizes_during_overlap
    assert_access('new-test-key', true)
  end

  def test_unknown_and_blank_keys_fail_both_checks
    [nil, '', ' ', 'incorrect-test-key'].each { |key| assert_access(key, false) }
  end

  def test_absent_or_blank_overlap_does_not_grant_access
    [nil, '', ' '].each do |overlap|
      ENV['app_key_next'] = overlap
      assert_access('old-test-key', true)
      assert_access(overlap, false)
      assert_access('new-test-key', false)
    end
  end

  def test_previous_key_is_rejected_after_promotion
    replace_primary('new-test-key')
    ENV.delete('app_key_next')
    assert_access('new-test-key', true)
    assert_access('old-test-key', false)
  end

  private

  def assert_access(key, expected)
    controller = ProbeController.new
    controller.params = { app_key: key }
    controller.send(:require_app_key)
    assert_equal expected, controller.rendered.nil?, 'controller authentication'
    assert_equal expected, controller.current_ability.can?(:manage, :all), 'CanCan authorization'
    assert_equal 401, controller.rendered[:status] unless expected
  end

  def replace_primary(value)
    Api::V0::ApiController.send(:remove_const, :APP_KEY)
    Api::V0::ApiController.const_set(:APP_KEY, value)
  end
end
