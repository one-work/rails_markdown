module Markdown
  module Model::GithubApp
    extend ActiveSupport::Concern

    included do
      attribute :client_id, :string
    end

    def oauth2_url(scope: 'user,repo,gist', state: SecureRandom.alphanumeric(32), **url_options)
      url_options.with_defaults!(
        controller: '/home',
        action: 'login',
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

  end
end
