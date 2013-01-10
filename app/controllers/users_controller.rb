class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        @user.create_client(@salon)
        format.html { redirect_to root_path, notice: 'User was successfully created.' }
      else
        format.html { render "new" }
      end
    end
  end

end
