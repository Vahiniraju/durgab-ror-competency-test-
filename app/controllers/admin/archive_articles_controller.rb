class Admin::ArchiveArticlesController < ApplicationController
  before_action :set_article, only: %i[create]
  access admin: %i[create]

  def create
    if @article.update(archived: true)
      redirect_to article_path(@article), success: 'Article is archived.'
    else
      redirect_to article_path(@user), alert: 'Could not archive article.'
    end
  end

  def set_article
    @article = Article.find params[:article_id]
    return redirect_to root_path, alert: 'Article is already archived.' if @article.archived
  end
end
