import React from 'react';
import { storiesOf } from '@storybook/react';
import { text, select, boolean, withKnobs } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';
import DefaultEmptyState, { EmptyStatePattern } from './index';
import Story from '../../../../../../stories/components/Story';

storiesOf('Components/Empty State Pattern', module)
  .addDecorator(withKnobs)
  .add('Default', () => (
    <Story>
      <EmptyStatePattern
        icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
        header={text('header', 'This is the header')}
        description={text('description', 'Your description goes here!')}
      />
    </Story>
  ))
  .add('with Primary Action', () => (
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
  ))
  .add('with Primary and Secondary Actions', () => (
    <Story>
      <EmptyStatePattern
        icon={select('icons', ['add-circle-o', 'edit', 'key', 'print'], 'key')}
        header={text('header', 'Header')}
        description={text('description', 'Description!')}
        action={
          <button
            onClick={action('create clicked')}
            className="btn btn-primary"
          >
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
  ))
  .add('with customized Documentation', () => (
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
  ))
  .add('Foreman Empty State', () => {
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
      </Story>
    );
  });
