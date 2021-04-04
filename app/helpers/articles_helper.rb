module ArticlesHelper
  def options_for_category(category)
    category_id = category.id if category
    options_for_select(Category.all.map { |cat| [cat.name, cat.id] }, selected: category_id)
  end
end
