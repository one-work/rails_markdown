module Markdown
  class Panel::GithubAppsController < Panel::BaseController

    private
    def git_params
      params.fetch(:github_app, {}).permit(
        :client_id,
        :client_secret
      )
    end

  end
end
