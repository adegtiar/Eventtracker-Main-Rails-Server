class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:init,:check_phone_number, 
                                                           :verify_password]
  
  def init
    @user = User.find_or_create_by_phone_number(params[:phone_number])
    # Mark all events as deleted. This is done in case the user had an account with 
    # a given phone number and then decided to create another account with the same number
    @user.events.each do |event|  
      event.deleted = true
      event.save
    end  
    @user.uuid = params[:uuid]
    @user.password = params[:password]

    #respond_to do |format|
      if @user.save
        render :text => 'OK', :status => 201
      else
        render :text => @user.errors, :status => 400
      end
    #end
  end

  # Checks to see if an account already exists with this phone number
  def check_phone_number
    @user = User.find_by_phone_number(params[:phone_number])

    if @user.nil?
      # No account exists with this phone number
      render :text => 'false', :status => 201
    else
      # account exists with this phone number
      render :text => 'true', :status => 201
    end
  end

  def verify_password
    @user = User.find_by_phone_number(params[:phone_number])
    if @user.valid_password? params[:password]
      # account exists with this phone number and passwords match
      response = {'uuid' => @user.uuid, 'status' => 'verified'}
      render :json => response, :status => 201 
    else
      # passwords dont match
      response = {'status' => 'unverified'}
      render :json => response , :status => 201
    end
  end
end
