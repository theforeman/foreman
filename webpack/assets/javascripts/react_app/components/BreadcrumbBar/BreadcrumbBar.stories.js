import React from 'react';
import { boolean, number } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';

import BreadcrumbBar from './BreadcrumbBar';
import Story from '../../../../../stories/components/Story';

export default {
  title: 'Components/BreadcrumbBar',
};

export const withOpenSwitcher = () => (
  <Story>
    <BreadcrumbBar
      isLoadingResources={boolean('is loading', false)}
      loadSwitcherResourcesByResource={action('load switcher data')}
      isSwitcherOpen={boolean('is switcher open', true)}
      total={number('total pages', 3)}
      currentPage={number('current page', 2)}
      hasError={boolean('has error', false)}
      resourceSwitcherItems={[
        { name: 'item 1', id: 1 },
        { name: 'item 2', id: 2 },
        {
          name:
            'item 3 with a very very  very very very very very very long name',
          id: 3,
        },
      ]}
      resource={{
        resourceUrl: 'some_url',
      }}
      isSwitchable={true}
      breadcrumbItems={[
        { caption: 'Index Page', url: '#' },
        { caption: 'Resource Page' },
      ]}
    />
  </Story>
);

withOpenSwitcher.story = {
  name: 'With open switcher',
};
