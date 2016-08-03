require 'securerandom'

class UsersController < UserActionController
  skip_before_action :validate_session_exists, only: [:create, :reset_password, :change_password]
  before_action :validate_installation_exists, only: :create
  skip_before_action :validate_api_key, only: [:change_password, :reset_password]

  def create
    if @session
      output_error(204, "User already logged in, please logout first.")
      return
    end

    if User.find_by("username = ? OR email = ?", params[:data][:username], params[:data][:username]) != nil
      output_error(303, "Username already exists.")
      return
    end

    if params[:data][:email] && params[:data][:email].length > 0 && User.find_by("username = ? OR email = ?", params[:data][:email], params[:data][:email]) != nil
      output_error(303, "Email already exists.")
      return
    end

    user = User.new

    if params[:data][:city]
      city_id = params[:data][:city][:id]
      if city_id != 0 && city_id != '0'
        user.city_id = city_id
      elsif params[:data][:city][:state]
        state_id = params[:data][:city][:state][:id]

        city = City.find_by(name: params[:data][:city][:name])

        if city
          user.city_id = city.id
        else
          city = City.new
          city.name = params[:data][:city][:name]
          city.state_id = state_id
          if city.save
            user.city_id = city.id
          else
            puts "City error " + city.errors.messages.flatten(2).to_s
          end
        end
      end
    end

    user.attributes = params.require(:data).permit([
      :first_name,
      :last_name,
      :gender,
      :username,
      :password,
      :address,
      :zip_code,
      :street_address,
      :email,
      :birthdate,
      :bio,
      :link
      ])
    if user.save
      params[:data][:login_type] = 1
      login(params[:data])
    else
      output_error(302, "Failed to save user. " + user.errors.messages.flatten(2).to_s)
    end
  end

  def show
    if params[:id] == "me"
      params[:id] = @session.user.id
    end
    
    output (User.find(params[:id]))
  end

  def update
    if params[:id] == "me"
      params[:id] = @session.user.id
    end

    if params[:id].to_i != @session.user.id
      output_error(306, "Object access is not permitted")
      return
    end

    parameters = params.require(:data)

    if parameters[:bio]
      parameters[:bio] = parameters[:bio].strip
    end

    @session.user.attributes = parameters.permit([
      :first_name,
      :last_name,
      :gender,
      :username,
      :address,
      :zip_code,
      :street_address,
      :birthdate,
      :bio,
      :link
      ])

    profile_picture_id = 0

    if params[:data][:profile_picture_id]
      profile_picture_id = params[:data][:profile_picture_id].to_i
    elsif params[:data][:profile_picture]
      profile_picture_id = params[:data][:profile_picture][:id]
    end

    if profile_picture_id != 0 && !validate_file(profile_picture_id)
      return
    end

    if profile_picture_id != 0
      @session.user.profile_picture_id = profile_picture_id
    end

    if params[:data][:city]
      city_id = params[:data][:city][:id]
      if city_id != 0 && city_id != '0'
        @session.user.city_id = city_id
      elsif params[:data][:city][:state]
        state_id = params[:data][:city][:state][:id]

        city = City.find_by(name: params[:data][:city][:name])

        if city
          @session.user.city_id = city.id
        else
          city = City.new
          city.name = params[:data][:city][:name]
          city.state_id = state_id
          if city.save
            @session.user.city_id = city.id
          else
            puts "City error " + city.errors.messages.flatten(2).to_s
          end
        end
      end
    end

    if @session.user.save
      output (@session.user)
    else
      output_error(303, "Failed to save user. " + @session.user.errors.messages.flatten(2).to_s)
    end
  end

  def search
    query = params[:query]
    follows_only = params[:follows]
    user_id = nil
    if follows_only
      user_id = @session.user_id
    end
    users = User.unblocked(@session.user).search(query, user_id).limit(get_limit).offset(get_offset)
    output users
  end

  def followers
    id = params[:id]
    if id == "me"
      id = @session.user.id
    end
    followers = User.unscoped.find(id).followers.limit(get_limit).offset(get_offset)
    output (followers)
  end

  def follows
    id = params[:id]
    if id == "me"
      id = @session.user.id
    end
    follows = User.unscoped.find(id).follows.limit(get_limit).offset(get_offset)
    output (follows)
  end

  def follow
    flag = params[:flag] ? params[:flag] == '1' || params[:flag] == 'true' : true
    type = 3
    object = User.find(params[:id])
    perform_action(flag, type, object, object)
    output (object)
  end

  def report
    flag = params[:flag] ? params[:flag] == '1' || params[:flag] == 'true' : true
    type = 11
    object = User.find(params[:id])
    perform_action(flag, type, object, object)
    output (object)
  end

  def block
    flag = params[:flag] ? params[:flag] == '1' || params[:flag] == 'true' : true
    type = 12
    object = User.find(params[:id])
    perform_action(flag, type, object, object)
    output (object)
  end

  def update_email
    if params[:id] == "me"
      params[:id] = @session.user_id
    end

    if params[:id].to_i != @session.user_id
      output_error(306, "Object access is not permitted")
      return
    end

    if !params[:password]
      output_error(401, "Missing password.")
      return
    end

    if !params[:email]
      output_error(401, "Missing parameter: email.")
      return
    end

    if @session.user.authenticate(params[:password])
        @session.user.email = params[:email]
        @session.user.save
        output (@session.user)
    else
      output_error(206, "Invalid password")
    end
  end

  def reset_password
    email = params[:email]

    if !email
      output_error(401, "Missing parameter: email.")
    end

    user = User.find_by(email: email)
    valid_email = @session ? user != nil && user.id == @session.user_id : user != nil
    if valid_email
      random_code = SecureRandom.hex
      expire_date = DateTime.now + 2.day

      password_reset_code = PasswordResetCode.create(user_id: user.id, code: random_code, expire_date: expire_date)
      UserMailer.reset_password(user, request.base_url + '/change_password.html?code=' + random_code).deliver_now
    
      render_json({})
    else 
      output_error(206, "Invalid email")
    end
  end

  def change_password
    flash[:notice] = nil
    code = params[:code]
    if !code
      flash[:notice] = 'Missing reset password code.'
    end

    password_reset_code = PasswordResetCode.find_by(code: code)
    if !password_reset_code || password_reset_code.expired?
      flash[:notice] = "Invalid or expired code. Please request to reset your password again."
      password_reset_code = nil
    end

    if params[:password] && params[:password].length >= 6
      password_reset_code.user.password = params[:password]
      if password_reset_code.user.save
        password_reset_code.used = 1
        password_reset_code.save
        flash[:notice] = "Password has been updated successfully."
        password_reset_code = nil
      else
        flash[:notice] = "An error occured with saving your password."
        puts "Password change error " + password_reset_code.user.errors.flatten(2).to_s
      end
    elsif params[:password] && params[:password].length < 6
      flash[:notice] = "Password is too short, it must be more than 6 characters."
    end

    output(password_reset_code)
  end

end
