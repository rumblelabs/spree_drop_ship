module Spree
  module Admin
    class DropShipOrdersController < Spree::Admin::BaseController

      # def deliver
      #   @order = DropShipOrder.accessible_by(current_ability, :show).find(params[:id])
      #   if @order.deliver
      #     flash[:notice] = t('spree.admin.drop_ship_orders.deliver.success', number: @order.id)
      #   else
      #     flash[:error] = t('spree.admin.drop_ship_orders.deliver.error', number: @order.id)
      #   end
      #   redirect_to spree.admin_drop_ship_order_path(@order)
      # end

      def index
        params[:q] ||= {}
        params[:q][:completed_at_not_null] ||= '1' if Spree::Config[:show_only_complete_orders_by_default]
        @show_only_completed = params[:q][:completed_at_not_null].present?
        params[:q][:s] ||= @show_only_completed ? 'completed_at desc' : 'created_at desc'

        # As date params are deleted if @show_only_completed, store
        # the original date so we can restore them into the params
        # after the search
        created_at_gt = params[:q][:created_at_gt]
        created_at_lt = params[:q][:created_at_lt]

        params[:q].delete(:inventory_units_shipment_id_null) if params[:q][:inventory_units_shipment_id_null] == "0"

        if !params[:q][:created_at_gt].blank?
          params[:q][:created_at_gt] = Time.zone.parse(params[:q][:created_at_gt]).beginning_of_day rescue ""
        end

        if !params[:q][:created_at_lt].blank?
          params[:q][:created_at_lt] = Time.zone.parse(params[:q][:created_at_lt]).end_of_day rescue ""
        end

        if @show_only_completed
          params[:q][:completed_at_gt] = params[:q].delete(:created_at_gt)
          params[:q][:completed_at_lt] = params[:q].delete(:created_at_lt)
        end

        @search = DropShipOrder.accessible_by(current_ability, :index).ransack(params[:q])
        @orders = @search.result.includes([:user, :shipments, :payments]).
          page(params[:page]).
          per(params[:per_page] || Spree::Config[:orders_per_page])

        # Restore dates
        params[:q][:created_at_gt] = created_at_gt
        params[:q][:created_at_lt] = created_at_lt
      end

      def show
        @order = DropShipOrder.accessible_by(current_ability, :show).find(params[:id])
      end

    end
  end
end
