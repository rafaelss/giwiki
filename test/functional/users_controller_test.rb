require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead
  # Then, you can remove it from this and the units test.
  include AuthenticatedTestHelper

  fixtures :users

  def test_should_allow_signup
    assert_difference 'User.count' do
      create_user
      assert_response :redirect
    end
  end

  def test_should_require_name_on_signup
    assert_no_difference 'User.count' do
      create_user(:name => nil)
      assert assigns(:user).errors.on(:name)
      assert_response :success
    end
  end

  def test_should_require_login_on_signup
    assert_no_difference 'User.count' do
      create_user(:login => nil)
      assert assigns(:user).errors.on(:login)
      assert_response :success
    end
  end

  def test_should_require_password_on_signup
    assert_no_difference 'User.count' do
      create_user(:password => nil)
      assert assigns(:user).errors.on(:password)
      assert_response :success
    end
  end

  def test_should_require_password_confirmation_on_signup
    assert_no_difference 'User.count' do
      create_user(:password_confirmation => nil)
      assert assigns(:user).errors.on(:password_confirmation)
      assert_response :success
    end
  end

  def test_should_require_email_on_signup
    assert_no_difference 'User.count' do
      create_user(:email => nil)
      assert assigns(:user).errors.on(:email)
      assert_response :success
    end
  end

  def test_whithout_login_should_not_edit_account
    get :edit_current

    assert_redirected_to root_path
  end

  def test_whithout_login_should_not_update_account
    put :update_current, :id => 1, :user => { }

    assert_redirected_to root_path
  end

  def test_should_get_edit_as_admin
    login_as :quentin
    get :edit, :id => users(:aaron).id
    assert_response :success
  end

  def test_should_not_get_edit_as_editor
    login_as :aaron
    get :edit, :id => users(:quentin).id
    assert_response :missing
  end

  def test_should_not_get_edit_as_contributor
    login_as :sam
    get :edit, :id => users(:quentin).id
    assert_response :missing
  end

  def test_should_update_user
    login_as :quentin
    put :update, :id => 1, :user => { }
    assert_redirected_to users_path()
  end

  def test_should_update_user_without_needing_password
    login_as :quentin
    put :update, :id => users(:sam).id, :user => { :email => 'sam@newemail.com'}
    assert_redirected_to users_path
    assert_not_equal users(:sam).email, assigns(:user).email
  end

  def test_should_update_password_with_confirmation
    login_as :quentin
    put :update, :id => users(:sam).id, :user => { :password => 'newpass', :password_confirmation => 'newpass'}
    assert_redirected_to users_path
    assert flash.has_key?(:notice)
  end

  def test_should_not_update_password_with_wrong_confirmation
    login_as :quentin
    put :update, :id => users(:sam).id, :user => { :password => 'newpass', :password_confirmation => 'notnewpass'}
    assert !flash.has_key?(:notice)
  end

  def test_should_not_update_password_with_blank_confirmation
    login_as :quentin
    put :update, :id => users(:sam).id, :user => { :password => 'newpass', :password_confirmation => '' }
    assert !flash.has_key?(:notice)
  end

  def test_admin_can_destroy_user
    login_as :quentin
    old_count = User.count
    delete :destroy, :id => 2
    assert_equal old_count-1, User.count

    assert_redirected_to users_path
  end

  def test_normal_user_cannot_destroy_others
    login_as :sam
    old_count = User.count
    delete :destroy, :id => 1
    assert_equal old_count, User.count

    assert_response :missing
  end

  def test_should_set_admin
    assert !users(:sam).admin?

    login_as :quentin
    put :update, :id => users(:sam).id, :user => { :role => 'administrator'}
    assert_redirected_to users_path

    assert users(:sam).reload.admin?
  end

  def test_should_create_user_as_contributor
    create_user :role => 'admin'

    assert_redirected_to root_path

    assert !assigns(:user).admin?
  end

  protected
    def create_user(options = {})
      post :create, :user => { :name => 'Quire', :login => 'quire', :email => 'quire@example.com',
        :password => 'quire69', :password_confirmation => 'quire69' }.merge(options)
    end
end
