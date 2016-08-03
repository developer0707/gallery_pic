class Admin::RoundsController < Admin::ApplicationController
  def index
    @rounds =  Round.all.includes(:winning_posts).unscoped.order(:end_date)
    output(@rounds)
  end

  def new
    now = DateTime.now
    @round = Round.new
    @round.start_date = DateTime.new(now.year, now.month, now.mday, 22, 0, 0)
    @round.end_date = DateTime.new(now.year, now.month, now.mday, 22, 0, 0)
  end
  
  def create
    round_data = params.require(:round).permit([:start_date, :end_date])
    Round.create(round_data)
    redirect_to admin_rounds_path({ secret_token: params[:secret_token] })
  end
  
  def destroy
    round = Round.find(params[:id])
    round.destroy
    redirect_to admin_rounds_path({ secret_token: params[:secret_token] })
  end
end
