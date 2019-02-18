import React from '@theforeman/vendor/react';
import { storiesOf } from '@storybook/react';
import Story from '../../../../../stories/components/Story';
import MockPagination from './PaginationWrapper.fixtures';

storiesOf('Components/Pagination', module).add('Show paginated items', () => (
  <Story narrow>
    <MockPagination />
  </Story>
));
