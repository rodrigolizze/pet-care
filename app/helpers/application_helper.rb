module ApplicationHelper
  # Always returns a wa.me link with a prefilled message
  def wa_link_for(user, booking, as:)
    number = user.try(:phone_number).to_s.gsub(/\D/, "")
    number = "5511999999999" if number.blank? # demo fallback

    role_line = (as == :client) ? "Sou o cliente da reserva" : "Sou o cuidador da reserva"
    msg = "Olá, #{user.name}! #{role_line} de #{booking.availability.date.strftime('%d/%m/%Y')} do pet #{booking.pet_name}."
    "https://wa.me/#{number}?text=#{ERB::Util.url_encode(msg)}"
  end
end
