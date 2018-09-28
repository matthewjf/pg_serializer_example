class Api::ProductsController < ApplicationController
  def index
    render json: Product.all.as_json_array
  end

  def show
    head :ok
  end
end
