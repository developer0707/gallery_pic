require 'koala'
require 'securerandom'
require "browser"

##
# Base controller for ActionController::Base which provides helper methods for validating request
# and output helpers.

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :validate_api_key
  respond_to :json, :xml, :html
  rescue_from Exception, :with => :handle_exception

  # Handles exceptions within controllers by adding log message and returning "Internal Server Error" message
  def handle_exception(error)
    puts request.method + ":" + request.url + " " + error.message
    puts error.backtrace.to_s
    output_error 500, "Internal Server Error"
  end

  def ssl_required? #:nodoc:
    Rails.env.production?
  end

  ##
  # Validates API key or authenitcation method given in +params+.
  # Expected paramters in order +access_token+, +installation_key+ and +api_key+
  def validate_api_key
    # puts request.method + ":" + request.url + " browser:" + browser.to_s + " ip:" + request.remote_ip
    if params[:access_token]
      validate_access_token
    elsif params[:installation_key]
      validate_installation_key
    elsif !params[:api_key]
      output_error(1, "Missing API Key")
    elsif params[:api_key] != 'fa8acaf23e85c71b5f261fb2016e2548'
      output_error(2, 'Invalid Api Key')
    end
  end

  # Validates +installation_key+ parameter if it exists.
  def validate_installation_key
    key = params[:installation_key]
    if !key
      return
    end

    @installation = Installation.find_by(installation_key: params[:installation_key])
    if !@installation
      output_error(102, 'Invalid/Expired Installation Key')
      return
    end
  end

  # Validates that +@installation+ exists.
  def validate_installation_exists
    if !@installation
      output_error(101, 'Missing installation key')
    end
  end

  # Validates +access_token+ key if it exists.
  def validate_access_token
    token = params[:access_token]

    if !token
      return
    end

    @session = Session.find_by(access_token: params[:access_token])
    if !@session
      output_error(202, 'Invalid/Expired Access Token')
      return
    end
    @installation = @session.installation
  end

  ##
  # Validates that <tt>@session</tt> exists
  # this means a valid access token is available
  def validate_session_exists
    if !@session
      output_error(201, 'Missing access token')
    end
  end

  ##
  # Validates that a secret token is valid.
  # This is used for private API calls, such as imports.
  def validate_secret_token
    if params[:secret_token] != '65eb2a63e0990015dcc7995de227fbca'
      render_json({ :well => "well"})
    end
  end

  ##
  # Uses +render_json+ to return an error with +code+ and +message+
  # Ex response:
  ## {
  ##  "error": {
  ##  "code": code,
  ##  "message": message
  ##   }
  ## }
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

  # Renders +data+ using <tt>render(:json => data.to_json)</tt>
  def render_json(data)
    render(:json => data.to_json)
  end

  # Sets +value+ as <tt>@data</tt> and +respond_with+ it
  def output(value)
    @data = value
    respond_with(@data)
  end

  ##
  # Logs user in using +params+
  # +login_type+ is required with +1+ for login using username/email password
  # or +2+ for Facebook login.
  # +username+ and +password+ are required when <tt>login_type == 1</tt>
  # +facebook_token+ is required when <tt>login_type == 2</tt>
  # Output errors if an error occurred or sets <tt>@session</tt> and <tt>@installation</tt>
  # then invokes <tt>output(@session)</tt>
  def login(params)
    login_type = params[:login_type]

    if !login_type
      output_error(401, "Missing Login type.")
      return
    end

    login_type = login_type.to_i

    if login_type == 1
      username = params[:username]
      password = params[:password]

      if !username
        output_error(401, "Missing username or email.")
        return
      end

      if !password
        output_error(401, "Missing password.")
        return
      end

      user = User.find_by(username: username)

      if !user
        user = User.find_by(email: username)
      end

      if !user || !user.authenticate(params[:password])
        output_error(204, "Invalid username or password")
        return
      end
    elsif login_type == 2
      facebook_token = params[:facebook_token]
      expire_date = params[:expire_date]

      if !facebook_token
        output_error(401, "Missing facebook_token")
        return
      end

      @graph = Koala::Facebook::API.new(facebook_token)

      profile = @graph.get_object("me")

      facebook_id = profile["id"]

      user = User.find_by(facebook_id: facebook_id)

      facebook_profile_picture = 'https://graph.facebook.com/' +  facebook_id +'/picture'
      profileFile = MediaFile.find_or_create_by(parse_url: facebook_profile_picture)
      if !user
        user = User.new
        # user.profile_picture = 'https://graph.facebook.com/' +  facebook_id +'/picture?=' + facebook_token + "&width=1000"
      end
      #updating user's info with each facebook login
      user.attributes = {
        :profile_picture => profileFile,
        :facebook_id => facebook_id,
        :facebook_token => facebook_token,
        :first_name => profile["first_name"],
        :last_name => profile["last_name"],
        :gender => profile["gender"],
        :email => profile["email"],
        :name => profile["name"],
        :username => profile["first_name"].downcase + "." + profile["last_name"].downcase
      }

      if !user.password
        random_password = Array.new(10).map { (65 + rand(58)).chr }.join
        user.password = random_password
      end

      if !user.save
        output_error(303, "Couldn't save user. " + user.errors.messages.flatten(2).to_s)
        return
      end

    else
      output_error(205, "Unsupported login type = " + login_type.to_s)
      return
    end

    @session = Session.new
    @session.attributes = {:user => user, 
      :access_token => SecureRandom.hex, 
      :installation => @installation}

    if @session.save
      @installation.user = user
      @installation.save
      puts @session.user.to_json
      output (@session)
    else
      output_error(303, "Failed to save session. " + @session.errors.messages.flatten(2).to_s)
    end
  end

  # Returns +offset+ value from +params+ or +0+
  def get_offset
    return params[:offset] ? params[:offset] : 0
  end

  # Invokes +get_limit_default(10)+
  def get_limit
    return get_limit_default(10)
  end

  # Returns +limit+ value from +params+ or +default+
  def get_limit_default(default)
    return params[:limit] ? params[:limit] : default
  end    

end
