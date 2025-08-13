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

  def bulk_create
    sitter = User.find(params[:sitter_id])
    return redirect_to user_path(sitter), alert: "Você não pode reservar a sua própria disponibilidade." if sitter.id == current_user.id

    begin
      start_date = Date.parse(params[:start_date])
      end_date   = Date.parse(params[:end_date])
    rescue ArgumentError
      return redirect_to user_path(sitter), alert: "Datas inválidas."
    end
    return redirect_to user_path(sitter), alert: "Período inválido." if end_date < start_date

    range = (start_date..end_date).to_a

    availabilities = sitter.availabilities
                           .where(date: range)
                           .left_outer_joins(:booking)
                           .where(bookings: { id: nil })
                           .order(:date)

    available_dates = availabilities.pluck(:date)
    missing = range - available_dates
    if missing.any?
      msg = "Um ou mais dias indisponíveis: " + missing.map { |d| d.strftime('%d/%m/%Y') }.join(', ')
      return redirect_to user_path(sitter), alert: msg, status: :see_other
    end

    group_token = SecureRandom.uuid   # <-- all bookings in this batch share this token

    ApplicationRecord.transaction do
      availabilities.each do |a|
        Booking.create!(
          user:           current_user,
          availability:   a,
          pet_name:       params[:pet_name],
          animal_type:    params[:animal_type],
          pet_size:       params[:pet_size],
          pet_birth_year: params[:pet_birth_year],
          group_token:    group_token
        )
      end
    end

    success_msg = "Reservas criadas para #{range.size} dia(s): #{range.map { |d| d.strftime('%d/%m/%Y') }.join(', ')}."
    redirect_to user_path(sitter), notice: success_msg, status: :see_other
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    redirect_to user_path(sitter), alert: "Não foi possível criar as reservas. Tente novamente.", status: :see_other
  end

  def destroy
    availability = Availability.find(params[:availability_id])
    booking = availability.booking
    return redirect_to user_path(availability.user), alert: "Reserva não encontrada." unless booking

    # authorize: sitter (owner) or client (owner of booking)
    unless availability.user == current_user || booking.user == current_user
      return redirect_to user_path(availability.user), alert: "Acesso restrito."
    end

    if booking.group_token.present?
      # cancel the whole batch
      bookings = Booking.where(group_token: booking.group_token)
      count = bookings.count
      bookings.destroy_all
      redirect_to user_path(availability.user), notice: "Reserva em período cancelada (#{count} dia(s)).", status: :see_other
    else
      booking.destroy
      redirect_to user_path(availability.user), notice: "Reserva cancelada.", status: :see_other
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:pet_name, :animal_type, :pet_size, :pet_birth_year)
  end

  def require_client
    redirect_to root_path, alert: "Acesso restrito." unless current_user.client?
  end

  def bulk_booking_params
      # same fields as your single-day form
      params.permit(:pet_name, :animal_type, :pet_size, :pet_birth_year)
  end
end
