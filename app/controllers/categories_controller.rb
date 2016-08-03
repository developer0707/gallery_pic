class CategoriesController < UserActionController

  def index
  	categories = Category.order(:order).limit(get_limit_default(24)).offset(get_offset)
  	output (categories)
  end

end
