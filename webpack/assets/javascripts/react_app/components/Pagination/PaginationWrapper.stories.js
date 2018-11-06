import React from 'react';
import { storiesOf } from '@storybook/react';

import MockPagination from './PaginationWrapper.fixtures';

storiesOf('Components/Pagination', module)
  .add('Show paginated items', () => (
    <div style={{ width: '600px', paddingTop: '200px' }}>
      <MockPagination />
    </div>));
