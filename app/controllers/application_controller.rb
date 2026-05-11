class ApplicationController < ActionController::API
  rescue_from ArgumentError, with: :handle_bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :handle_unprocessable

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user

    render json: { error: "Not authorized" }, status: :unauthorized
  end

  def handle_bad_request(error)
    render json: { error: error.message }, status: :unprocessable_entity
  end

  def handle_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def handle_unprocessable(error)
    render json: { error: error.record.errors.full_messages }, status: :unprocessable_entity
  end
end