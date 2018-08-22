import React from 'react';
import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';
import DocumentationLink, { DocumentLinkContent } from './index';

storiesOf('Components/DocumentationLink', module)
  .add('Default', () => (
    <div>
      <ul>
        <DocumentationLink handleClick={action('Link was clicked')} href="#" />
      </ul>
    </div>
  ))
  .add('DocumentLinkContent wrapped in a button', () => (
    <div>
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
    </div>
  ))
  .add('DocumentLinkContent', () => <DocumentLinkContent />);
