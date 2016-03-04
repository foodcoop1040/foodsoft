# encoding: utf-8
class Admin::OrdergroupsController < Admin::BaseController
  inherit_resources

  def index
    @ordergroups = params[:show_deleted] ? Ordergroup.deleted : Ordergroup.undeleted

    # if somebody uses the search field:
    unless params[:query].blank?
      @ordergroups = @ordergroups.where('name LIKE ?', "%#{params[:query]}%")
    end

    @ordergroups = @ordergroups.order('name ASC').page(params[:page]).per(@per_page)
  end

  def destroy
    @ordergroup = Ordergroup.find(params[:id])
    @ordergroup.mark_as_deleted
    redirect_to admin_ordergroups_url, notice: t('admin.ordergroups.destroy.notice')
  rescue => error
    redirect_to admin_ordergroups_url, alert: t('admin.ordergroups.destroy.error')
  end

  def restore
    @ordergroup = Ordergroup.find(params[:id])
    @ordergroup.restore
    redirect_to admin_ordergroups_url, notice: t('admin.ordergroups.restore.notice')
  rescue => error
    redirect_to admin_ordergroups_url, alert: t('admin.ordergroups.restore.error')
  end
end
