require 'test_helper'

class Admin::VisitorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_visitors_index_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_visitors_destroy_url
    assert_response :success
  end

end
