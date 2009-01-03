require 'digest/sha1'

# This controller handles the login/logout function of the site.
class SessionsController < ApplicationController

  # render new.rhtml
  def new
  end

  def open_id
  end

	def create
		logout_keeping_session!

		if params[:openid_url] == "http://"
			params[:openid_url] = nil
		end

		if using_open_id?
			open_id_authentication(params[:openid_url])
		else
			password_authentication(params[:login], params[:password])
		end
	end

	def open_id_authentication(openid_url)
		authenticate_with_open_id(openid_url, :required => [:fullname,:nickname, :email]) do |result, identity_url, registration|
			if result.successful?
				@user = User.find_or_initialize_by_identity_url(identity_url)
				if @user.new_record?
					@user.name = registration['fullname']
					@user.login = registration['nickname']
					@user.email = registration['email']
					@user.created_at = DateTime.now
					@user.salt = Digest::SHA1.hexdigest(identity_url)
					@user.save(false)
				end
				self.current_user = @user
				successful_login
			else
				failed_login result.message
			end
		end
	end

	def password_authentication(login, password)
		user = User.authenticate(login, password)
		if user
		  # Protects against session fixation attacks, causes request forgery
		  # protection if user resubmits an earlier form using back
		  # button. Uncomment if you understand the tradeoffs.
		  # reset_session
		  self.current_user = user
		  successful_login
		else
		  failed_login
		end
	end

  def destroy
	logout_killing_session!
	flash[:notice] = "You have been logged out."
	redirect_back_or_default('/')
  end

protected

	def successful_login
		new_cookie_flag = (params[:remember_me] == "1")
		handle_remember_cookie! new_cookie_flag
		flash[:notice] = "Logged in successfully"
		redirect_back_or_default(root_url)
	end

	def failed_login (message = "")
		if using_open_id?
			@openid_url = params[:openid_url]
			flash[:error] = "Couldn't log you with Open ID - '#{message}'"
			logger.warn "Failed login for '#{params[:openid_url]}' from #{request.remote_ip} at #{Time.now.utc} with message #{message}"
		else
			@login       = params[:login]
			@remember_me = params[:remember_me]
			flash[:error] = "Couldn't log you in as '#{params[:login]}'"
			logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
		end
		render :action => 'new'
	end
end
