class PagesController < ApplicationController
  def home
  search_params = params[:search] || {}

  @city = search_params[:city]
  @start_date = search_params[:start_date]
  @end_date = search_params[:end_date]

  sitters = User.where(role: "sitter").includes(availabilities: :booking)
  sitters = sitters.where("address ILIKE ?", "%#{@city}%") if @city.present?

  if @start_date.present? && @end_date.present?
    begin
      start_date = Date.parse(@start_date)
      end_date = Date.parse(@end_date)
      requested_dates = (start_date..end_date).to_a

      sitter_ids = User
        .joins(:availabilities)
        .where(role: "sitter", availabilities: { date: requested_dates })
        .group("users.id")
        .having("COUNT(DISTINCT availabilities.date) = ?", requested_dates.count)
        .pluck(:id)

      sitters = sitters.where(id: sitter_ids)
    rescue ArgumentError
      # Datas inválidas — ignorar ou tratar
    end
  end

  @sitters = sitters.includes(:availabilities)
  end
end
