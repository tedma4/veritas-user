class UsersController < ApplicationController
  # skip_before_action :authenticate_user_from_token!
  require 'string_image_uploader'
  before_action :set_user, only: [:update, :destroy, :search]

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params.to_h)
    @auth_token = jwt_token({user_id: @user.id.to_s})
    respond_to do |format|
      if @user.save
        format.json { render json: { auth_token: @auth_token, user: @user.build_user_hash, created_at: @user.created_at } }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update_attributes(user_params.to_h)
        format.json { render json: @user.build_user_hash, status: :ok }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def search
    if params[:search] && !params[:search].blank?
      @search = User.search(params[:search])
      if @user
        respond_with @search.map {|user| 
          user = User.find(user["id"])
          User.build_search_hash(user)#, @current_user)
        }
      else
        respond_with @search.map {|user| 
            # user = User.find(user["id"])
            User.build_search_hash(user)
          }
      end
    else
      @search = nil
      respond_with @search
    end
  end

  # def user_location
  #   # http://localhost:3000/v1/user_location?user_id=5856d773c2382f415081e8cd&location=-111.97798311710358,33.481907631522525&time_stamp=2017-01-15T18:01:24.734-07:00    
  #   if @current_user
  #     coords = User.add_location_data(@current_user.id, params[:location], params[:time_stamp])
  #     @current_user.area_watcher(coords)
  #     render json: {status: 200} #, auth_token: encoded_token}
  #   else
  #     render json: {errors: 400}
  #   end
  # end
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








