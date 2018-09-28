class Api::ProductsController < ApplicationController
  def index
    render json: Product.limit(3).order(updated_at: :desc).as_json_array
  end

  def show
    head :ok
  end
end
