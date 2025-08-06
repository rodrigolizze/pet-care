class BookingsController < ApplicationController

  before_action :authenticate_user!
  before_action :require_client

  def new
    @availability = Availability.find(params[:availability_id])
    @booking = Booking.new
  end

  def create
    @availability = Availability.find(params[:availability_id])
    @booking = Booking.new(booking_params)
    @booking.user = current_user
    @booking.availability = @availability

    if booking.save
      redirect_to rooth_path, notice: "Reserva criada com sucesso!"
    else
      render :new
    end
  end

  private

  def boooking_params
    params.require(:booking).permit(:pet_name, :animal_type, :pet_size, :pet_birth_year)
  end

  def require_client
    redirect_to rooth_path, alert: "Acesso restrito." unless current_user.client?
  end
end
