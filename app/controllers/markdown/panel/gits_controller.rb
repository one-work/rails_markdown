module Markdown
  class Panel::GitsController < Panel::BaseController
    before_action :set_git, only: [:show, :edit, :edit_github_user, :update, :destroy, :actions]

    def index
      @gits = Git.page(params[:page])
    end

    def edit_github_user
      @github_users = Auth::GithubUser.page(params[:page])
    end

    private
    def set_git
      @git = Git.find(params[:id])
    end

    def git_permit_params
      [
        :type,
        :working_directory,
        :base_name,
        :host,
        :github_user_id,
        :remote_url,
        :last_commit_at,
        :last_commit_message
      ]
    end

  end
end
