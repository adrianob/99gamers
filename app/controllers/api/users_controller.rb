class Api::UsersController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  def connect
    if params[:secret] != CatarseSettings[:api_secret]
      failure
      return
    end
    user = params['user']
    begin
      u= User.new(raiseit_id: user['id'],
                   raiseit_key: user['api_key'],
                   email: user['email'],
                   name: user['name']
                  )
      u.save!
      u.reload
    rescue
      render :json => { :error => "Error creating user" }, :status => 400
      return
    end

    render json: {api_key: u.authentication_token, id: u.id}.to_json, status: 200
  end

  def subscriptions
    if params[:secret] != CatarseSettings[:api_secret]
      failure
      return
    end
    user = User.find_by_authentication_token params[:authentication_token]
    subscriptions = user.projects.with_state(:online).last.subscriptions.active.order('subscriptions.created_at desc').limit(25)
    api_response = {
      "_total": subscriptions.count,
      "subscriptions": subscriptions_json(subscriptions)
    }
    render json: api_response.to_json, status: 200
  end

  private
  def failure
    render :json => { :error => "Login Credentials Failed" }, :status => 401
  end

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

