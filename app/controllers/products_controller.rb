class ProductsController < ApplicationController
  before_action :check_admin_priv, except: ["index", "show"]
  before_action :set_product, only: %i[show edit update destroy]

  def index
    permitted_params = params.permit(:keyword, :category_id, :filter, :page)
    
    @products = Product.all

    if permitted_params[:keyword].present?
      @products = @products.search_by_keyword(permitted_params[:keyword], permitted_params[:category_id])
    end

    case permitted_params[:filter]
    when 'on_sale'
      @products = @products.on_sale
    when 'new'
      @products = @products.new_products
    when 'recently_updated'
      @products = @products.recently_updated
    end

    @products = @products.page(permitted_params[:page]).per(8)

    # Debugging output
    Rails.logger.debug { "Search keyword: #{permitted_params[:keyword]}" }
    Rails.logger.debug { "Category ID: #{permitted_params[:category_id]}" }
    Rails.logger.debug { "Filter: #{permitted_params[:filter]}" }
    Rails.logger.debug { "Generated SQL: #{@products.to_sql}" }
    Rails.logger.debug { "Products found: #{@products.inspect}" }
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)
    @product.description = "Default description" if @product.description.blank?

    respond_to do |format|
      if @product.save
        session[:last_created_product_id] = @product.id
        flash[:custom_notice] = "Product was successfully created."
        format.html { redirect_to product_url(@product), notice: flash[:custom_notice] }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    new_product_params = product_params.to_unsafe_h
    new_product_params.delete("images") if new_product_params["images"].all?(&:blank?)

    respond_to do |format|
      if @product.update(new_product_params)
        format.html { redirect_to product_url(@product), notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_url, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.require(:product).permit(:name, :description, :price, :category_id, images: [])
  end
end
