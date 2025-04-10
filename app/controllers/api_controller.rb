# frozen_string_literal: true

class ApiController < ActionController::API

  def render_success_json(data, payload = {})
    response = {
      status: 200,
      success: true,
      message: 'Success',
      data: data
    }.merge(payload)

    render json: response
  end
end