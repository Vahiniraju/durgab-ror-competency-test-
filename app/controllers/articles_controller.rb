class ArticlesController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  before_action :set_article, only: %i[show edit update destroy]
  before_action :can_edit?, only: %i[edit update]
  before_action :can_destroy?, only: :destroy
  access all: [:index], %i[user admin editor] => %i[index show],
         [:editor] => %i[new edit destroy create update]

  def index
    @articles = Article.all
    @can_create_articles = logged_in?(:admin, :editor)
  end

  def show; end

  def new
    @article = Article.new
  end

  def edit; end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      redirect_to @article, success: 'Article was successfully created.'
    else
      render :new
    end
  end

  def update
    if @article.update(article_params)
      redirect_to @article, success: 'Article was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    if @article.destroy
      redirect_to articles_path, success: 'Article was successfully destroyed.'
    else
      redirect_to articles_path, alert: 'Something went wrong.'
    end
  end

  private

  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content, :category_id)
  end

  def can_edit?
    return redirect_to @article, notice: 'Permission Denied' unless @article.user.id == current_user.id
  end

  def can_destroy?
    return redirect_to articles_path, notice: 'Permission Denied' unless @article.user.id == current_user.id
  end
end
