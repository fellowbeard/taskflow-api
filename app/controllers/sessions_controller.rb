class SessionsController < ApplicationController
  def create
    user = User.find_by!(name: params[:name])

    render json: {
      id: user.id,
      name: user.name
    }
  end
end