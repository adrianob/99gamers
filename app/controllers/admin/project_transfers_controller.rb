class Admin::ProjectTransfersController < Admin::BaseController
  layout 'catarse_bootstrap'

  has_scope  :by_id, :pg_search, :with_state,  :order_by

  before_filter do
    @total_project_transfers = ProjectTransfer.count(:all)
  end

  [:confirm, :unconfirm].each do |name|
    define_method name do
      @project_transfer = ProjectTransfer.find params[:id]
      @project_transfer.send("#{name.to_s}")
      redirect_to :back
    end
  end

  def update
    resource.update_attributes(permitted_params)
    super
  end

  protected
  def permitted_params
    params.require(:project_transfer).permit(resource.attribute_names.map(&:to_sym))
  end

  def collection
    @scoped_project_transfers = apply_scopes(ProjectTransfer)
    @project_transfers = @scoped_project_transfers.page(params[:page])
  end
end
