# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from Aserto::AccessDenied do |exception|
    render json: { error: exception.message }, status: :unauthorized
  end
end
