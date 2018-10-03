class Api::ProductsController < ApplicationController
  def index
    request.format = :json
    # @products = Product.limit(200).order(updated_at: :desc).includes(:categories, :label, variations: :color)
    # render 'api/products/index.json.jbuilder'

    render json: Product.limit(200).order(updated_at: :desc).json
  end

  def show
    render json: Product.find(params[:id]).json
  end
end
