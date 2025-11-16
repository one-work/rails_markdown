module Markdown
  class Panel::PostsController < Panel::BaseController
    before_action :set_git
    before_action :set_post, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:title, :catalog_path, 'path-rl')

      @posts = @git.posts.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def sync
      @git.sync_later
    end

    private
    def set_git
      @git = Git.find params[:git_id]
    end

    def set_post
      @post = @git.posts.find(params[:id])
    end

    def post_permit_params
      [
        :layout,
        :published,
        :nav,
        :shared,
        :target,
        :position
      ]
    end

  end
end
