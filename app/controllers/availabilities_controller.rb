class AvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_sitter

  def index
    @availabilities = current_user.availabilities
  end

  def new
    @availability = Availability.new
  end

  def create
    @availability = current_user.availabilities.build(availability_params)
    if @availability.save
      redirect_to availabilities_path, notice: "Dispomibilidade criada com sucesso."
    else
      render :new
    end
  end

  private

  def availability_params
    params.require(:availability).permit(:date)
  end

  def require_sitter
    redirect_to root_path, alert: "Acesso restrito." unless current_user.sitter?
  end
end
