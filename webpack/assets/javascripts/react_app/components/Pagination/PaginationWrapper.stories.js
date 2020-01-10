import React from 'react';
import Story from '../../../../../stories/components/Story';
import MockPagination from './PaginationWrapper.fixtures';

export default {
  title: 'Components|Pagination',
};

export const showPaginatedItems = () => (
  <Story narrow>
    <MockPagination />
  </Story>
);

showPaginatedItems.story = {
  name: 'Show paginated items',
};
