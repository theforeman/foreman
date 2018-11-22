import React from 'react';
import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';
import DocumentationLink, { DocumentLinkContent } from './index';
import Story from '../../../../../../stories/components/Story';

storiesOf('Components/DocumentationLink', module)
  .add('Default', () => (
    <Story>
      <ul>
        <DocumentationLink handleClick={action('Link was clicked')} href="#" />
      </ul>
    </Story>
  ))
  .add('DocumentLinkContent wrapped in a button', () => (
    <Story>
      <button className="btn btn-default">
        <DocumentLinkContent />
      </button>
      <button className="btn btn-primary">
        <DocumentLinkContent />
      </button>
      <button className="btn btn-warning">
        <DocumentLinkContent />
      </button>
      <button className="btn btn-danger">
        <DocumentLinkContent />
      </button>
    </Story>
  ))
  .add('DocumentLinkContent', () => (
    <Story>
      <DocumentLinkContent />
    </Story>
  ));
