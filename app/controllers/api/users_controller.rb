class Api::UsersController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }

  def create
    @result = HTTParty.post('http://raiseit.tv/api/connect',
    :body => {
              secret: CatarseSettings[:raiseit_secret],
              user: {
                id: current_user.id,
                api_key: current_user.authentication_token,
                email: current_user.email,
                name: current_user.name
               }
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )

    current_user.update_attributes(raiseit_key: @result.parsed_response['api_key'], raiseit_id: @result.parsed_response['id'])
    redirect_to(:back)
  end

  def connect
    if params[:secret] != CatarseSettings[:api_secret]
      failure
      return
    end
    user = params['user']
    begin
      u = User.find_or_create_by(email: user['email']) do |new_user|
        new_user.raiseit_id = user['id']
        new_user.raiseit_key = user['api_key']
        new_user.name = user['name']
      end
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
    if !user
      render json: { :error => "User not found" }.to_json, status: 404
      return
    end
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

