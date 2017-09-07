# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  http_basic_authenticate_with name: 'user', password: 'secret', only: :authenticate

  def show
    status = :ok

    if (id = params.delete(:id)).to_i.positive?
      response = { id: id.to_i, name: 'Test User' }
    else
      response = { message: 'User not found' }
      status = :not_found
    end

    response[:created_at] = rand.days.ago if params[:random]

    respond_to do |format|
      format.json do
        render json: response, status: status
      end
      format.xml do
        render xml: response.to_xml(root: 'user'), status: status
      end
    end
  end

  def authenticate
    render json: { message: 'Authenticated' }
  end
end
