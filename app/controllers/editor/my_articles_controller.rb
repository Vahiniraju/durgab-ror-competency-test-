class Editor::MyArticlesController < ApplicationController
  access editor: %i[index]

  def index
    @articles = current_user.unscoped_articles.where('title LIKE ?', "%#{search_field}%")
                            .includes(:category).page(params[:page])
  end

  private

  def search_field
    params.permit![:search_field]
  end
end
