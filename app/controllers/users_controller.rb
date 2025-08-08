class UsersController < ApplicationController
  before_action :authenticate_user!  # ensure only logged-in users can view profiles

  def show
    @user = User.find(params[:id])
    # Only show future availabilities of this sitter (optional but recommended)
    @availabilities = @user.availabilities.where("date >= ?", Date.today).order(:date)
  end
end
