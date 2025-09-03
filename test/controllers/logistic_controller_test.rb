require "test_helper"

class LogisticControllerTest < ActionDispatch::IntegrationTest
  test "should get route" do
    get logistic_route_url
    assert_response :success
  end
end
