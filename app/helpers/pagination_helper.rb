module PaginationHelper
  def will_paginate_with_info(collection = nil, options = {})
    if collection.total_entries.zero?
      render plain: _('No entries found')
    else
      render('common/pagination', collection: collection, options: options)
    end
  end

  def per_page_options(options = [5, 10, 15, 25, 50])
    options << Setting[:entries_per_page].to_i
    options << params[:per_page].to_i if params[:per_page].present?
    options.uniq.sort
  end

  def react_pagination_props(collection = nil, classname = nil)
    {
      viewType: 'table',
      itemCount: collection.total_entries,
      perPageOptions: per_page_options,
      perPage: Setting[:entries_per_page],
      classNames: {pagination_classes: classname},
    }
  end
end
