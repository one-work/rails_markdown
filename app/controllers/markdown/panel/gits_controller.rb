module Markdown
  class Panel::GitsController < Panel::BaseController
    before_action :set_git, only: [:show, :edit, :update, :destroy, :actions]

    def index
      @gits = Git.page(params[:page])
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
        :remote_url,
        :last_commit_at,
        :last_commit_message
      ]
    end

  end
end
