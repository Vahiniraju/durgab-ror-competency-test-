class Admin::ArchiveArticlesController < ApplicationController
  before_action :set_article, only: %i[create]
  access admin: %i[create]

  def create
    if @article.update(archived: true)
      redirect_to articles_path, success: 'Article is archived.'
    else
      redirect_to article_path(@user), alert: 'Could not archive article.'
    end
  end

  def set_article
    @article = Article.unscoped.find params[:article_id]
    return redirect_to admin_user_path(@article.user), alert: 'Article is already archived.' if @article.archived
  end
end
