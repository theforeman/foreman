import React from 'react';
import { storiesOf } from '@storybook/react';
import PageTitle from './PageTitle';

storiesOf('Layout', module)
  .add('Page Title', () => <PageTitle text={'Penguins'} />);
