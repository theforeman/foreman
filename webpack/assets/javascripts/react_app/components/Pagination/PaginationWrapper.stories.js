import React from 'react';
import { storiesOf } from '@theforeman/stories';
import Story from '../../../../../stories/components/Story';
import MockPagination from './PaginationWrapper.fixtures';

storiesOf('Components|Pagination', module).add('Show paginated items', () => (
  <Story narrow>
    <MockPagination />
  </Story>
));
