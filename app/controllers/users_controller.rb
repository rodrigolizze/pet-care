class UsersController < ApplicationController
  before_action :authenticate_user! # ensure only logged-in users can view profiles
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @user = User.find(params[:id])
    # Only show future availabilities of this sitter (optional but recommended)
    @availabilities = @user.availabilities.where("date >= ?", Date.today)
                           .includes(booking: :user)   # avoid N+1
                           .order(:date)
  end

  def become_sitter
    # show the form for extra sitter details
  end

  # def activate_sitter
  #   if current_user.update(user_params.merge(role: "sitter")) # or sitter: true
  #     redirect_to sitter_users_path, notice: "You are now a sitter!"
  #   else
  #     render :become_sitter, status: :unprocessable_entity
  #   end
  # end

  def activate_sitter
    if current_user.update(user_params.merge(sitter: true))
      redirect_to sitter_users_path, notice: "You are now a sitter!"
    else
      render :become_sitter, status: :unprocessable_entity
    end
  end


  def sitter_dashboard
    unless current_user.sitter?
      redirect_to root_path, alert: "You are not authorized to access this page."
      return
  end

  # Example: fetch sitter's availabilities
  @availabilities = current_user.availabilities

  # This view will allow them to add new available dates
  end

  private

  def user_params
    params.require(:user).permit(:name, :birth_date, :cpf, :email, :address, :bio, :experience, :photo, :property_type, :property_type, :backyard, :has_pet, :screened_windows, :animal_sizes, :city)
  end

end
