
require "net/http"
require "json"

class UsersController < ApplicationController
  def new
    logger.info "UsersController new called"
    @user = User.new
  end





  def create
    logger.info "UsersController create called"
    index
    logger.info "User params inspect #{user_params.inspect}"

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

      redirect_to new_domain_crawler_path
    else
      logger.info "catpcha unverified"
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
