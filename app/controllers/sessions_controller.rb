class SessionsController < ApplicationController
  skip_before_action :authenticate_user_from_token!, only: [:create]
  before_action :ensure_params_exist

  def create
    @user = User.where(email: user_params[:email]).first
    return invalid_login_attempt unless @user
    return invalid_login_attempt unless @user.authenticate(user_params[:password])
    jwt_user_hash = {user_id: @user.id.to_s}
    auth_token = jwt_token(jwt_user_hash)
    if Session.where(user_id: @user.id, archived_at: nil).any?
      session = Session.where(user_id: @user.id).first
    else
      session = Session.new(user_id: @user.id, jwt: auth_token )
      session.save
    end
    render json: {
      auth_token: auth_token, 
      user: @user.build_user_hash,
      created_at: Time.now
    }
  end

  def destroy
    # session = JsonWebToken.decode(request.header["HTTP_AUTHORIZATION"])[:data][:user_id]
    sesh = Session.where(user_id: @current_user.id).first
    sesh.archived_at = Time.now
    sesh.save
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def ensure_params_exist
    if user_params[:email].blank? || user_params[:password].blank?
      return render_unauthorized errors: { unauthenticated: ["Incomplete credentials"] }
    end
  end

  def invalid_login_attempt
    self.status = :unauthorized
    self.response_body = { error: 'Access denied' }

    # render_unauthorized errors: { unauthenticated: ["Invalid credentials"] }
  end
end