class ArticlesController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  before_action :set_article, only: %i[show edit update destroy]
  before_action :can_edit?, only: %i[edit update]
  before_action :can_destroy?, only: :destroy
  access all: [:index], %i[user admin editor] => %i[index show],
         [:editor] => %i[new edit destroy create update]

  def index
    @articles = Article.all if current_user
    @articles = Article.where(id: Article.n_article_ids_by_category) unless current_user
    @articles = @articles.includes(:user, :category).page(params[:page])
    @can_create_articles = logged_in?(:editor)
  end

  def show
    @can_edit =  check_user_eligible
    @can_archive = logged_in?(:admin) && !@article.archived
  end

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
    @article = Article.find_by_id(params[:id])
    @article = Article.unscoped.find_by_id(params[:id]) if logged_in?(:admin, :editor) && !@article
    return redirect_to root_path, alert: 'Article not found or its archived by admin' unless @article
  end

  def article_params
    params.require(:article).permit(:title, :content, :category_id)
  end

  def can_edit?
    return redirect_to @article, notice: 'Permission Denied' unless check_user_eligible

    return redirect_to @article, notice: 'Artilcle archived cannot be edited' if @article.archived
  end

  def can_destroy?
    return redirect_to articles_path, notice: 'Permission Denied' unless check_user_eligible
  end

  def check_user_eligible
    @article.user.id == current_user.id && logged_in?(:editor)
  end
end
