class Api::ProductsController < ApplicationController
  def index
    render json: Product.limit(3).order(updated_at: :desc).json
  end

  def show
    render json: Product.find(params[:id]).json
  end
end
