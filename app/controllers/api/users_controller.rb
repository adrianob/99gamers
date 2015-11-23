class Api::UsersController < ApplicationController

  def subscriptions
    if params[:secret] != CatarseSettings[:api_secret]
      failure
      return
    end
    user = User.find_by_authentication_token params[:authentication_token]
    subscriptions = user.projects.with_state(:online).last.subscriptions.order('subscriptions.created_at desc').limit(25)
    api_response = {
      "_total": subscriptions.count,
      "subscriptions": subscriptions_json(subscriptions)
    }
    render json: api_response.to_json, status: 200
  end

  def failure
    render :json => { :error => "Login Credentials Failed" }, :status => 401
  end

  private
  def subscriptions_json(subscriptions)
    json = []
    subscriptions.each do |subscription|
      json << {
        "_id": subscription.id,
        "user": {
          "_id": subscription.user.id,
          "logo": nil,
          "type": "user",
          "bio": subscription.user.about_html,
          "created_at": subscription.user.created_at,
          "name": subscription.user.name,
          "updated_at": subscription.user.updated_at,
          "display_name": subscription.user.display_name,
        },
        "created_at": subscription.created_at,
      }
    end
    json

  end
end

