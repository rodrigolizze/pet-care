class AvailabilitiesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_sitter

  def index
    @availabilities = current_user.availabilities.order(:date)
  end

  def new
    @availability = Availability.new
  end

  def create
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    if end_date < start_date
      redirect_to new_availability_path, alert: "A data de término não pode ser anterior à data de início."
      return
    end

    created = 0

    (start_date..end_date).each do |date|
      current_user.availabilities.find_or_create_by(date: date)
      created += 1
    end

    redirect_to availabilities_path, notice: "#{created} disponibilidade(s) criada(s) com sucesso."
  rescue ArgumentError
    redirect_to new_availability_path, alert: "Datas inválidas."
  end

  def destroy
    @availability = current_user.availabilities.find(params[:id])
    @availability.destroy
    redirect_to availabilities_path, notice: "Disponibilidade excluída."
  end


  private

  def availability_params
    params.require(:availability).permit(:date)
  end

  def require_sitter
    redirect_to root_path, alert: "Acesso restrito." unless current_user.sitter?
  end
end
