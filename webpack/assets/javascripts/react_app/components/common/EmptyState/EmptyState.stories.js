import React from 'react';
import { Provider } from 'react-redux';
import store from '../../../redux';
import { text, select, boolean, withKnobs, action } from '@theforeman/stories';
import { Button } from '@patternfly/react-core';
import DefaultEmptyState, { EmptyStatePattern } from './index';
import Story from '../../../../../../stories/components/Story';

export default {
  title: 'Components|Empty State Pattern',
  decorators: [withKnobs],
};

export const defaultStory = () => (
  <Story>
    <EmptyStatePattern
      icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
      header={text('header', 'This is the header')}
      description={text('description', 'Your description goes here!')}
    />
  </Story>
);

defaultStory.story = {
  name: 'Default',
};

export const withPrimaryAction = () => (
  <Story>
    <EmptyStatePattern
      icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
      header={text('header', 'Header')}
      description={text('description', 'Description!')}
      action={
        <Button onClick={action('doing something')}>Do Something now!</Button>
      }
    />
  </Story>
);

withPrimaryAction.story = {
  name: 'with Primary Action',
};

export const withPrimaryAndSecondaryActions = () => (
  <Story>
    <EmptyStatePattern
      icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
      header={text('header', 'Header')}
      description={text('description', 'Description!')}
      action={
        <Button onClick={action('create clicked')} variant="primary">
          Create
        </Button>
      }
      secondaryActions={
        <React.Fragment>
          <Button onClick={action('reading')} variant="secondary">
            Read
          </Button>
          <Button onClick={action('retrying')} variant="tertiary">
            Retry
          </Button>
          <Button onClick={action('destroying')} variant="danger">
            Destroy
          </Button>
        </React.Fragment>
      }
    />
  </Story>
);

withPrimaryAndSecondaryActions.story = {
  name: 'with Primary and Secondary Actions',
};

export const withCustomizedDocumentation = () => (
  <Story>
    <EmptyStatePattern
      icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
      header={text('header', 'Header')}
      description={text('description', 'Description!')}
      documentation={
        <React.Fragment>
          To read more about this click on the link below
          <br />
          <a href="#">Documentation</a>
        </React.Fragment>
      }
    />
  </Story>
);

withCustomizedDocumentation.story = {
  name: 'with customized Documentation',
};

export const foremanEmptyState = () => {
  const customizeDocLabel = boolean('customize doc label', false);
  const customizeDocButtonLabel = boolean('customize button label', false);
  const docObject = { url: '#' };
  if (customizeDocLabel) {
    docObject.label = text('documentation label', 'Read documents ->');
  }
  if (customizeDocButtonLabel) {
    docObject.buttonLabel = text('documentation button label', 'Click here');
  }
  return (
    <Story>
      <Provider store={store}>
        <DefaultEmptyState
          icon={select(
            'icons',
            ['add-circle-o', 'edit', 'key', 'print'],
            'key'
          )}
          header={text('header', 'Header')}
          description={text('description', 'Description!')}
          documentation={docObject}
          action={{
            title: text('primary action title', 'Primary'),
            url: text('primary action url', '#'),
          }}
          secondaryActions={[
            {
              title: text('secondary action title', 'Secondary'),
              url: text('secondary action url', '#'),
            },
          ]}
        />
      </Provider>
    </Story>
  );
};
