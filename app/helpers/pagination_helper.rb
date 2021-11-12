module PaginationHelper
  def will_paginate_with_info(collection = nil, options = {})
    if collection.total_entries.zero?
      render plain: _('No entries found')
    else
      render('common/pagination', collection: collection, options: options)
    end
  end
end
