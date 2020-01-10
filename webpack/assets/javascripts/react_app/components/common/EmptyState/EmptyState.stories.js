import React from 'react';
import { text, select, boolean, withKnobs, action } from '@theforeman/stories';

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
        <button onClick={action('doing something')}>Do Something now!</button>
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
        <button onClick={action('create clicked')} className="btn btn-primary">
          Create
        </button>
      }
      secondaryActions={
        <React.Fragment>
          <button onClick={action('reading')} className="btn btn-default">
            Read
          </button>
          <button onClick={action('retrying')} className="btn btn-success">
            Retry
          </button>
          <button onClick={action('destroying')} className="btn btn-danger">
            Destroy
          </button>
          <button onClick={action('reloading')} className="btn btn-warning">
            Reload
          </button>
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
  const customizeDocButtonLabel = boolean('costumize button label', false);
  const docObject = { url: '#' };
  if (customizeDocLabel) {
    docObject.label = text('documentation label', 'Read documents ->');
  }
  if (customizeDocButtonLabel) {
    docObject.buttonLabel = text('documentation button label', 'Click here');
  }
  return (
    <Story>
      <DefaultEmptyState
        icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
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
    </Story>
  );
};
