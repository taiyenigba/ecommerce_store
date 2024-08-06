class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @orders = current_user.orders.includes(:cart)
    Rails.logger.debug "User: #{current_user.email}"
    Rails.logger.debug "Orders: #{@orders.inspect}"
  end

  def show
    @order = current_user.orders.find(params[:id])
  end
end



