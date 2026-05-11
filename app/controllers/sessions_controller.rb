class SessionsController < ApplicationController
  def create
    name = params[:name].to_s.strip
    password = params[:password].to_s

    if name.blank? || password.blank?
      return render json: { error: "Name and password required" }, status: :unprocessable_entity
    end

    user = User.find_by("LOWER(name) = ?", name.downcase)

    if user
      unless user.authenticate(password)
        return render json: { error: "Invalid password" }, status: :unauthorized
      end
    else
      user = User.create!(name: name, password: password)
    end

    session[:user_id] = user.id

    render json: { id: user.id, name: user.name }
  end

  def show
    user = current_user

    if user
      render json: { id: user.id, name: user.name }
    else
      render json: { error: "Not logged in" }, status: :unauthorized
    end
  end

  def destroy
    reset_session
    head :no_content
  end
end