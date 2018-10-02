class Api::VariationsController < ApplicationController
  def index
    render json: Variation.limit(3).order(updated_at: :desc).json
  end

  def show
    render json: Variation.find(params[:id]).json
  end
end
