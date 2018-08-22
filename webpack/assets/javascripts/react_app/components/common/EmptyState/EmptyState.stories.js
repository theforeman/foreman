import React from 'react';
import { storiesOf } from '@storybook/react';
import { text, select, boolean, withKnobs } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';
import DefaultEmptyState, { EmptyStatePattern } from './index';

storiesOf('Components/Empty State Pattern', module)
  .addDecorator(withKnobs)
  .add('Default', () => (
    <EmptyStatePattern
      icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
      header={text('header', 'This is the header')}
      description={text('description', 'Your description goes here!')}
    />
  ))
  .add('with Primary Action', () => (
    <EmptyStatePattern
      icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
      header={text('header', 'HEADER')}
      description={text('description', 'DESCRIPTION!')}
      action={
        <button onClick={action('doing something')}>Do Something now!</button>
      }
    />
  ))
  .add('with Primary and Secondary Actions', () => (
    <EmptyStatePattern
      icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
      header={text('header', 'HEADER')}
      description={text('description', 'DESCRIPTION!')}
      action={
        <button onClick={action('create clicked')} className="btn-primary">
          Create
        </button>
      }
      secondaryActions={
        <React.Fragment>
          <button onClick={action('reading')} className="btn-default">
            Read
          </button>
          <button onClick={action('retrying')} className="btn-success">
            Retry
          </button>
          <button onClick={action('destroying')} className="btn-danger">
            Destroy
          </button>
          <button onClick={action('reloading')} className="btn-warning">
            Reload
          </button>
        </React.Fragment>
      }
    />
  ))
  .add('with customized Documentation', () => (
    <EmptyStatePattern
      icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
      header={text('header', 'HEADER')}
      description={text('description', 'DESCRIPTION!')}
      documentation={
        <React.Fragment>
          To read more about this click on the link below<br />
          <a href="#">Documentation</a>
        </React.Fragment>
      }
    />
  ))
  .add('Foreman Empty State', () => {
    const customizeDocLabel = boolean('customize doc label', false);
    const customizeDocButtonLabel = boolean('costumize button label', false);
    const docObject = { url: '#' };
    if (customizeDocLabel) {
      docObject.label = text('documentation label', 'Read documents ->');
    }
    if (customizeDocButtonLabel) {
      docObject.buttonLabel = text(
        'documentation button label',
        'Click here',
      );
    }
    return (
      <DefaultEmptyState
        icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
        header={text('header', 'HEADER')}
        description={text('description', 'DESCRIPTION!')}
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
    );
  });
