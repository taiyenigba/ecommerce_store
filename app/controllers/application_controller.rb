class ApplicationController < ActionController::Base
  before_action :set_current_cart

  protected

  def check_admin_priv
    redirect_to root_path unless current_admin
  end

  private

  def set_current_cart
    if session[:current_cart_id]
      @current_cart = Cart.find_by_secret_id(session[:current_cart_id])
      if @current_cart && current_user && !@current_cart.user
        @current_cart.update(user_id: current_user.id)
      end
    else
      if current_user && current_user.carts.any?
        @current_cart = current_user.carts.last
        session[:current_cart_id] = @current_cart.secret_id
      else
        @current_cart = Cart.create(user: current_user)
        session[:current_cart_id] = @current_cart.secret_id
      end
    end
    flash[:notice] = "Cart updated for user #{current_user.email}." if current_user
  end
end
