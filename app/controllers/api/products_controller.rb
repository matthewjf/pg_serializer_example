class Api::ProductsController < ApplicationController
  def index
    # request.format = :json
    # @products = Product.limit(200)
    #                    .order(updated_at: :desc)
    #                    .includes(:categories, :label, variations: :color)
    # render 'api/products/index.json.jbuilder'

    render json: Product.limit(200).order(updated_at: :desc).json
    # render json: ProductSerializer.new(@products).serialized_json
  end

  def fast_jsonapi
    @products = Product.limit(200)
                       .order(updated_at: :desc)
                       .includes(:categories, :label, variations: :color)
    render json: ProductSerializer.new(@products).serialized_json
  end

  def pg_serializable
    render json: Product.limit(200).order(updated_at: :desc).json
  end

  def jbuilder
    @products = Product.limit(200)
                       .order(updated_at: :desc)
                       .includes(:categories, :label, variations: :color)
    render 'api/products/index.json.jbuilder'
  end

  def show
    render json: Product.find(params[:id]).json
  end
end
