module BookingsHelper
  # Always returns a wa.me link with a prefilled message
  # Falls back to a demo number if no phone is set
  def wa_link_for(user, booking, as:)
    number = user.try(:phone_number).to_s.gsub(/\D/, "")
    number = "5511999999999" if number.blank? # demo number fallback

    role_line =
      if as == :client
        "Sou o cliente da reserva"
      else
        "Sou o cuidador da reserva"
      end

    msg = "Olá, #{user.name}! #{role_line} de #{booking.availability.date.strftime('%d/%m/%Y')} do pet #{booking.pet_name}."
    "https://wa.me/#{number}?text=#{ERB::Util.url_encode(msg)}"
  end
end
