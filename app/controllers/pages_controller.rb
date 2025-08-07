class PagesController < ApplicationController
  def home
    @city = params[:city]
    @date = params[:date]

    sitters = User.where(role: "sitter")

    if @city.present?
      sitters = sitters.where("address ILIKE ?", "%#{@city}%")
    end

    if @date.present?
      begin
        search_date = Date.parse(@date)
        sitters = sitters.joins(:availabilities).where(availabilities: { date: search_date }).distinct
      end
    end

    @sitters = sitters.includes(:availabilities)
  end
end
