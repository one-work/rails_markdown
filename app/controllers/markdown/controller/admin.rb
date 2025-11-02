module Markdown
  module Controller::Admin
    extend ActiveSupport::Concern

    def current_github_user
      return @current_github_user if defined? @current_github_user
      @current_github_user = current_user.oauth_users.find_by(type: 'Auth::GithubUser')
      logger.debug "\e[35m  Current Github User: #{@current_github_user&.id}  \e[0m"
      @current_github_user
    end

  end
end
