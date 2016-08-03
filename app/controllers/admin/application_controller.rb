class Admin::ApplicationController < ActionController::Base
  before_action :validate_secret_token
  protect_from_forgery with: :null_session
  respond_to :json, :xml, :html
  rescue_from Exception, :with => :handle_exception

  def handle_exception(error)
    puts request.method + ":" + request.url + " " + error.message
    puts error.backtrace.to_s
    output_error 500, "Internal Server Error"
  end

  def validate_secret_token
    if params[:secret_token] != '65eb2a63e0990015dcc7995de227fbca'
      render_json({ :well => "well"})
    end
  end

  def render_json(data)
    render(:json => data.to_json)
  end

  def output(value)
    @data = value
    respond_with(@data)
  end

  def output_error(code, message)
  	error = { 
  				"error" =>
  				{
		  			"code" => code,
		  			"message" => message 
		  		}
  			}

    render_json(error)
  end

  def get_offset
    return params[:offset] ? params[:offset] : 0
  end

  def get_limit
    return get_limit_default(10)
  end

  def get_limit_default(default)
    return params[:limit] ? params[:limit] : default
  end

end
