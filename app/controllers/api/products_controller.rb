class Api::ProductsController < ApplicationController
  def index
    # request.format = :json
    # @products = Product.limit(3).order(updated_at: :desc)
    # render 'api/products/index.json.jbuilder'

    render json: Product.limit(3).order(updated_at: :desc).json
  end

  def show
    render json: Product.find(params[:id]).json
  end
end
