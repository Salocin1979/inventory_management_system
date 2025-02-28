require "test_helper"

class StockTransactionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get stock_transactions_index_url
    assert_response :success
  end

  test "should get show" do
    get stock_transactions_show_url
    assert_response :success
  end

  test "should get new" do
    get stock_transactions_new_url
    assert_response :success
  end

  test "should get create" do
    get stock_transactions_create_url
    assert_response :success
  end
end
