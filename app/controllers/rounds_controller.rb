class RoundsController < UserActionController
	def show
		id = params[:id]
		if id == 'active'
			round = Round.active_round
		else
			round = Round.find(id)
		end
		if round
			output (round)
		else
			message = id == 'active' ? "There's no active round." : "Invalid round id"
			output_error(301, message)
		end
	end

	def index
		rounds = Round.where.not(['start_date < ? AND end_date > ?', DateTime.now, DateTime.now]).order(end_date: :desc).limit(get_limit).offset(get_offset)
		output rounds
	end
end
