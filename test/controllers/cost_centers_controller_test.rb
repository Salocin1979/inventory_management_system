require "test_helper"

class CostCentersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cost_centers_index_url
    assert_response :success
  end

  test "should get show" do
    get cost_centers_show_url
    assert_response :success
  end

  test "should get new" do
    get cost_centers_new_url
    assert_response :success
  end

  test "should get create" do
    get cost_centers_create_url
    assert_response :success
  end

  test "should get edit" do
    get cost_centers_edit_url
    assert_response :success
  end

  test "should get update" do
    get cost_centers_update_url
    assert_response :success
  end

  test "should get destroy" do
    get cost_centers_destroy_url
    assert_response :success
  end
end
