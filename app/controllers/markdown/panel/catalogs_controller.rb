module Markdown
  class Panel::CatalogsController < Panel::BaseController
    before_action :set_git
    before_action :set_catalog, only: [:show, :edit, :update, :reorder, :catalog]

    def index
      @catalog = @git.catalogs.find_by(depth: 0)
      @catalogs = @git.catalogs.roots.order(position: :asc)
    end

    def all
      @catalogs = @git.catalogs.order(id: :desc)
    end

    private
    def set_git
      @git = Git.find params[:git_id]
    end

    def set_catalog
      @catalog = @git.catalogs.find params[:id]
    end

    def catalog_params
      params.fetch(:catalog, {}).permit(
        :nav
      )
    end

  end
end
