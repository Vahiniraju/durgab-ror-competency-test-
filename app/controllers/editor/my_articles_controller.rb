class Editor::MyArticlesController < ApplicationController
  access editor: %i[index]

  def index
    @articles = current_user.unscoped_articles.includes(:category).page(params[:page])
  end
end
