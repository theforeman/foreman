module PaginationHelper
  def will_paginate_with_info(collection = nil, options = {})
    if collection.total_entries.zero?
      render plain: _('No entries found')
    else
      render('common/pagination', collection: collection, options: options)
    end
  end

  def react_pagination_props(collection = nil, classname = nil)
    {
      viewType: 'table',
      itemCount: collection.total_entries,
      perPage: Setting[:entries_per_page],
      classNames: {pagination_classes: classname},
    }
  end
end
