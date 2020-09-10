import React from 'react';
import Story from '../../../../../stories/components/Story';
import MockPagination from './PaginationWrapper.fixtures';
import ContextFeatures from './Context.fixtures';
import { getForemanContext } from '../../Root/Context/ForemanContext';

const ForemanContext = getForemanContext();

export default {
  title: 'Components|Pagination',
  decorators: [
    StoryFn => (
      <ForemanContext.Provider value={ContextFeatures}>
        <StoryFn />
      </ForemanContext.Provider>
    ),
  ],
};

export const showPaginatedItems = () => (
  <Story narrow>
    <MockPagination />
  </Story>
);

showPaginatedItems.story = {
  name: 'Show paginated items',
};
