require 'test_helper'

class RFilesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:r_files)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create r_file" do
    assert_difference('RFile.count') do
      post :create, :r_file => { }
    end

    assert_redirected_to r_file_path(assigns(:r_file))
  end

  test "should show r_file" do
    get :show, :id => r_files(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => r_files(:one).to_param
    assert_response :success
  end

  test "should update r_file" do
    put :update, :id => r_files(:one).to_param, :r_file => { }
    assert_redirected_to r_file_path(assigns(:r_file))
  end

  test "should destroy r_file" do
    assert_difference('RFile.count', -1) do
      delete :destroy, :id => r_files(:one).to_param
    end

    assert_redirected_to r_files_path
  end
end
