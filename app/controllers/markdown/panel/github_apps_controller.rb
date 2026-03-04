module Markdown
  class Panel::GithubAppsController < Panel::BaseController

    private
    def github_app_params
      params.fetch(:github_app, {}).permit(
        :client_id,
        :client_secret
      )
    end

  end
end
