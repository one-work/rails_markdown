module Markdown
  module Model::GithubApp
    extend ActiveSupport::Concern

    included do
      attribute :client_id, :string
      attribute :client_secret, :string
      attribute :state, :string

      has_many :github_users, class_name: 'Auth::GithubUser', primary_key: :client_id, foreign_key: :appid
    end

    def oauth2_url(scope: 'user,repo,gist', **url_options)
      self.update state: SecureRandom.alphanumeric(32)
      url_options.with_defaults!(
        controller: '/oauth',
        action: 'github',
        appid: client_id
      )
      h = {
        client_id: client_id,
        redirect_uri: Rails.application.routes.url_for(**url_options),
        response_type: 'code',
        scope: scope,
        state: state
      }
      logger.debug "\e[35m  App Oauth2: #{h}  \e[0m"
      "https://github.com/login/oauth/authorize?#{h.to_query}"
    end

    def generate_github_user(code)
      result = HTTPX.plugin(:'proxy/ssh').with_proxy(**Rails.application.credentials[:proxy]).with(headers: { 'Accept' => 'application/json' }).post(
        'https://github.com/login/oauth/access_token',
        json: {
          client_id: client_id,
          client_secret: client_secret,
          code: code
        }
      )
      r = result.json
      logger.debug "\e[35m  Github App Generate User: #{r}  \e[0m"

      info = HTTPX.with(plugin: [:auth, :'proxy/ssh']).bearer_auth(r['access_token']).with_proxy(**Rails.application.credentials[:proxy]).get('https://api.github.com/user')
      user_info = info.json
      logger.debug "\e[35m  Github App info: #{user_info}  \e[0m"

      github_user = github_users.find_or_initialize_by(uid: user_info['id'])
      github_user.access_token = r['access_token']
      github_user
    end

  end
end
