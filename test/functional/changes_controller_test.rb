require 'test_helper'

class ChangesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:changes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create change" do
    assert_difference('Change.count') do
      post :create, :change => { }
    end

    assert_redirected_to change_path(assigns(:change))
  end

  test "should show change" do
    get :show, :id => changes(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => changes(:one).to_param
    assert_response :success
  end

  test "should update change" do
    put :update, :id => changes(:one).to_param, :change => { }
    assert_redirected_to change_path(assigns(:change))
  end

  test "should destroy change" do
    assert_difference('Change.count', -1) do
      delete :destroy, :id => changes(:one).to_param
    end

    assert_redirected_to changes_path
  end
end
