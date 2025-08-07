class PagesController < ApplicationController
  def home
    @sitters = User.includes(:availabilities).where(role: "sitter")
  end
end
