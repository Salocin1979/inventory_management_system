require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get reports_index_url
    assert_response :success
  end

  test "should get inventory_status" do
    get reports_inventory_status_url
    assert_response :success
  end

  test "should get transaction_history" do
    get reports_transaction_history_url
    assert_response :success
  end

  test "should get valuation_report" do
    get reports_valuation_report_url
    assert_response :success
  end
end
