class UsersController < ApplicationController
  skip_before_action :authenticate_user_from_token!, only: [:create]
  require 'string_image_uploader'
  before_action :set_user, only: [:update, :destroy, :search]

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params.to_h)
    @auth_token = jwt_token({user_id: @user.id.to_s})
    if @user.save
      render json: { auth_token: @auth_token, user: @user.build_user_hash, created_at: @user.created_at }
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    if @user.update_attributes(user_params.to_h)
      render json: @user.build_user_hash, status: :ok
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
  end

  def search
    if params[:search] && !params[:search].blank?
      @search = User.search(params[:search])
      if @user
        render json: @search.map {|user| 
          user = User.find(user["id"])
          User.build_search_hash(user)#, @current_user)
        }
      else
        render json: @search.map {|user| 
            # user = User.find(user["id"])
            User.build_search_hash(user)
          }
      end
    else
      @search = nil
      render json: @search
    end
  end
  private
  
  def user_params
    the_params = params.require(:user).permit(:first_name, :last_name, :user_name, :password, :email, :avatar)
    the_params[:avatar] = StringImageUploader.new(the_params[:avatar], "User").parse_image_data if the_params[:avatar]
    return the_params
  end

  def set_user
    @user = @current_user
  end
end








