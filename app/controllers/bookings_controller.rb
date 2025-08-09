class BookingsController < ApplicationController
  before_action :authenticate_user!
  # before_action :require_client

  def new
    @availability = Availability.find(params[:availability_id])
    @booking = Booking.new
  end

  def create
    @availability = Availability.find(params[:availability_id])

    if @availability.user_id == current_user.id
      return redirect_to user_path(@availability.user), alert: "Você não pode reservar a sua própria data."
    end

    @booking = Booking.new(booking_params)
    @booking.user = current_user
    @booking.availability = @availability

    if @booking.save
      redirect_to user_path(@availability.user), notice: "Reserva criada com sucesso!"
    else
      render :new
    end
  rescue ActiveRecord::RecordNotUnique
    # Unique index on bookings.availability_id fired → already taken
    redirect_to user_path(@availability.user), alert: "Esta data acabou de ser reservada por outra pessoa."
  end

  def available_dates
    @availabilities = Availability
                        .includes(:user)
                        .where("date >= ?", Date.today)
                        .order(:date)
  end

  def destroy
    availability = Availability.find(params[:availability_id])
    booking = availability.booking

    # if it's already free, just inform and return
    unless booking
      return redirect_to user_path(availability.user), notice: "Esta data já está livre."
    end

    # allow the sitter (owner of availability) or the client (owner of booking)
    unless availability.user == current_user || booking.user == current_user
      return redirect_to user_path(availability.user), alert: "Acesso restrito."
    end

    booking.destroy
    redirect_to user_path(availability.user), notice: "Reserva cancelada e data liberada."
  end

  def index
    # Bookings I made (as client)
    @my_bookings = current_user.bookings
                               .joins(:availability)
                               .includes(availability: :user) # sitter is availability.user
                               .order('availabilities.date ASC')

    # Bookings I received (as sitter)
    @received_bookings = Booking.joins(:availability)
                                .where(availabilities: { user_id: current_user.id })
                                .includes(:user, availability: :user) # client is booking.user
                                .order('availabilities.date ASC')
  end

  private

  def booking_params
    params.require(:booking).permit(:pet_name, :animal_type, :pet_size, :pet_birth_year)
  end

  def require_client
    redirect_to root_path, alert: "Acesso restrito." unless current_user.client?
  end
end
