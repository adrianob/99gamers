class Api::UsersController < ApplicationController
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }

  def create
    user = User.find params['user_id']
    return if current_user != user && !current_user.admin?
    @result = HTTParty.post('http://raiseit.tv/api/connect',
    :body => {
              secret: CatarseSettings[:raiseit_secret],
              user: {
                id: user.id,
                api_key: user.authentication_token,
                email: user.email,
                name: user.name
               }
             }.to_json,
    :headers => { 'Content-Type' => 'application/json' } )

    user.update_attributes(raiseit_key: @result.parsed_response['api_key'],
                                   reset_password_url: @result.parsed_response['reset_password_url'],
                                   raiseit_id: @result.parsed_response['id'])
    flash[:alert] = 'Integração com o Raiseit bem sucedida'
    redirect_to(:back)
  end

  def connect
    if params[:secret] != CatarseSettings[:api_secret]
      failure
      return
    end
    begin
      user = User.find_by_email params['user']['email']
      new_dbuser = false
      if !user
        new_dbuser = true
        user = User.create(email: params['user']['email']) do |new_user|
          new_user.raiseit_id = params['user']['id']
          new_user.raiseit_key = params['user']['api_key']
          new_user.name = params['user']['name']
        end
        user.reload
        user.send_reset_password_instructions
      end
    rescue
      render :json => { :error => "Error creating user" }, :status => 400
      return
    end

    render json: {api_key: user.authentication_token,
                  id: user.id,
                  new_user: new_dbuser,
                  reset_password_url: edit_user_password_url(user, reset_password_token: user.authentication_token)}.to_json, status: 200
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

