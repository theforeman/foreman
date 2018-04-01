import React from 'react';
import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';
import { ResourcesProps } from './BreadcrumbSwitcher.fixtures';
import BreadcrumbSwitcher from './';

storiesOf('Breadcrumb Switcher', module).add('breadcrumbs switcher', () => (
  <BreadcrumbSwitcher
    resources={[
      ...ResourcesProps.resources,
      {
        caption: 'Item with onClick',
        url: undefined,
        onClick: action('Item has been clicked'),
      },
    ]}
  />
));
