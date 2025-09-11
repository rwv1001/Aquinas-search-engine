
require "net/http"
require "json"

class UsersController < ApplicationController
  def new
    logger.info "UsersController new called"
    @user = User.new
  end
  def login_status
    render partial: "users/login_status"
  end





  def create
    logger.info "UsersController create called"
    logger.info "params keys: #{params.keys.inspect}"
    logger.info "g-recaptcha-response: #{params["g-recaptcha-response"]}"
    index
=begin
    logger.info "User params inspect #{user_params.inspect}"
    res = Net::HTTP.post_form(URI("https://www.google.com/recaptcha/api/siteverify"),
    secret: ENV["RECAPTCHA_SECRET_KEY"],
    response: params["g-recaptcha-response"],
    remoteip: request.remote_ip
)
result = JSON.parse(res.body)
Rails.logger.debug "Manual verification: #{result.inspect}"
=end
    @user = User.new(user_params)
    user_save = @user.save
    verify_captcha_value = verify_recaptcha(model: @user)
    unless verify_captcha_value
      Rails.logger.warn("Recaptcha verification failed: #{@user.errors[:recaptcha].inspect}")
    end
    logger.info "User save: #{user_save}, verify_captcha_value: #{verify_captcha_value}"

    if user_save and verify_captcha_value
      cookies[:auth_token] = @user.auth_token
      logger.info "catpcha verified"
      guest_user = current_user
      guest_user.destroy
      session[:user_id] =@user.id


      redirect_to domain_crawlers_url, notice: "Account successfully created! Welcome to St. Thomas the Search Engine."
    else
      if !verify_captcha_value
        @user.errors.add(:base, "CAPTCHA verification failed. Please try again.")
        logger.info "catpcha unverified"
      end
      if !user_save
        @user.errors.add(:base, "Unable to create user save: #{user_save} - either user already exists or the data is invalid")
        logger.info "user unverified"
      end

      render "new"
    end
  end

  def index
    logger.info "UsersController index called"
    @users = User.all
  end

  def update
    if @user.update_attributes(params[:user])
      sign_in @user
      flash[:success] = "Profile updated"
      redirect_to new_domain_crawler_path
    else
      render "edit"
    end
  end

  private

  def user_params
    logger.info "UsersController user_params called"
    params.require(:user).permit(:email, :first_name, :second_name, :password, :password_confirmation)
  end
end
