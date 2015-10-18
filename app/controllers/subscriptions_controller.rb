class SubscriptionsController < ApplicationController
  inherit_resources
  actions :index, :show, :new, :update, :review, :create
  after_filter :verify_authorized, except: [:index]
  belongs_to :plan
  before_filter :detect_old_browsers, only: [:create]

  helper_method :engine

  def edit
    @project = resource.plan.project
    authorize resource
  end

  def update
    authorize resource
    render json: {message: 'updated'}
  end

  def show
    authorize resource
  end

  def create
    @title = t('projects.subscriptions.create.title')
    @project = parent.project
    @subscription = parent.subscriptions.new
    @subscription.user = current_user
    @subscription.plan_id = params[:plan_id]
    authorize @subscription
    create! do |success,failure|
      failure.html do
        flash[:alert] = resource.errors.full_messages.to_sentence
        return redirect_to project_path(project_id: @project.id)
      end
      success.html do
        flash[:notice] = nil
        session[:thank_you_subscription_id] = @subscription.id
        return redirect_to edit_plan_subscription_path(parent, id: @subscription.id)
      end
    end
    @thank_you_id = @project.id
  end

  def toggle_anonymous
    authorize resource
    resource.toggle!(:anonymous)
    return render nothing: true
  end

  protected

  def permitted_params
    params.require(:subscription).permit(policy(resource).permitted_attributes)
  end

  def engine
    PaymentEngines.find_engine('Pagarme')
  end
end

