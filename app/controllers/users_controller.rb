class UsersController < ApplicationController
  before_filter :admin?, :only => [:index, :edit, :update, :destroy]
  before_filter :user_logged_in?, :only => [:edit_current, :update_current]

  # render new.rhtml
  def new
    @user = User.new
    render :layout => 'sessions'
  end

  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.login = params[:user][:login]
    @user.role = 'contributor'
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      self.current_user = @user # !! now logged in
      redirect_back_or_default(root_url)
    else
      render :layout => 'sessions', :action => 'new'
    end
  end

  def edit_current
    @user = current_user
  end

  def update_current
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Your account was successfully updated.'
      self.current_user = @user
      redirect_to account_url
    else
      render :action => "edit_current"
    end
  end

  # Admin operations

  def index
    @users = User.find(:all)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    unless params[:user][:role].blank?
      @user.role = params[:user][:role]
    end

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to(users_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = 'User was successfully destroyed.'

    redirect_to(users_url)
  end

private
  def admin?
    unless current_user.admin?
      render :file => "#{RAILS_ROOT}/public/404.html", :status => 404
    end
  end
  def user_logged_in?
    unless logged_in?
      redirect_to(root_url)
    end
  end
end
