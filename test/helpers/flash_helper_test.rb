require 'test_helper'

class FlashHelperTest < ActionView::TestCase
  test 'bootstrap_alert return string' do
    assert_equal 'info', bootstrap_alert('notice')
    assert_equal 'warning', bootstrap_alert('alert')
    assert_equal 'danger', bootstrap_alert('error')
    assert_equal 'success', bootstrap_alert('success')
  end
end
