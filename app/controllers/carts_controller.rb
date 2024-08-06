class CartsController < ApplicationController
  before_action :set_product, only: [:create, :destroy]
  before_action :authenticate_user!, only: [:checkout, :stripe_session, :success]

  def create
    if !@current_cart
      @current_cart = Cart.create(user: current_user)
      session[:current_cart_id] = @current_cart.secret_id
    end
    cart_item = @current_cart.cart_items.new(product_id: @product.id, quantity: 1) # Set default quantity to 1
    if cart_item.save
      session[:last_added_product_id] = @product.id
      redirect_to cart_path(@current_cart), notice: "Product added to cart successfully."
    else
      redirect_to cart_path(@current_cart), alert: "Failed to add product to cart: #{cart_item.errors.full_messages.join(', ')}"
    end
  end

  def show
    @current_cart = Cart.find_by_secret_id(session[:current_cart_id])
  end

  def checkout
    if !@current_cart&.cart_items&.any?
      redirect_to root_path, notice: "You don't have any items in your cart yet!"
    else
      @user = current_user
    end
  end

  def destroy
    @cart_item = @current_cart.cart_items.find_by(product_id: @product.id)
    @cart_item.destroy
    redirect_to cart_path(@current_cart)
  end

  def stripe_session
    @current_cart = Cart.find_by_secret_id(session[:current_cart_id])
    if @current_cart
      session = Stripe::Checkout::Session.create({
        payment_method_types: ['card'],
        line_items: [{
          price_data: {
            currency: 'usd',
            product_data: {
              name: @current_cart.products.map(&:name).join(", ")
            },
            unit_amount: (@current_cart.products.sum(&:price) * 100).to_i
          },
          quantity: 1
        }],
        mode: 'payment',
        success_url: success_cart_url(@current_cart.secret_id),
        cancel_url: cart_url(@current_cart),
        shipping_address_collection: {
          allowed_countries: ['US', 'CA']
        },
        customer_email: current_user.email
      })

      render json: { id: session.id }
    else
      render json: { error: 'Cart not found' }, status: :not_found
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def success
    @purchased_cart = Cart.find_by_secret_id(params[:id])
    if @purchased_cart && @purchased_cart.cart_items.any?
      session[:current_cart_id] = nil
      order = Order.new(
        user: current_user, 
        cart: @purchased_cart, 
        status: :complete, 
        total: @purchased_cart.products.sum(&:price)
      )
  
      if order.save
        Rails.logger.debug "Order created successfully: #{order.inspect}"
        @purchased_cart.cart_items.destroy_all # Clear the cart
        Rails.logger.debug "Cart items cleared for cart id: #{@purchased_cart.id}"
        redirect_to orders_path, notice: "Order successfully created."
      else
        Rails.logger.debug "Failed to create order: #{order.errors.full_messages.join(', ')}"
        redirect_to root_path, alert: "Failed to create order."
      end
    else
      Rails.logger.debug "Invalid cart or no items in the cart."
      redirect_to root_path, alert: "Invalid cart or no items in the cart."
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end
end
