import React from 'react';
import DefaultEmptyState, { EmptyStatePattern } from './index';
import PrimaryActionButton from './EmptyStatePrimaryActionButton';
import SecondaryActionButtons from './EmptyStateSecondaryActionButtons';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const defaultEmptyStateFixtures = {
  'should render documentation when given a url': {
    header: 'Printers',
    description: 'Printers print a file from the computer',
    action: { title: 'action-title', url: 'action-url' },
    documentation: { url: 'doc-url' },
  },
  'icon, header, description and main action are mandatory': {
    header: 'header1',
    description: 'description1',
    action: { title: 'action-title', url: 'action-url' },
  },
  'should render secondary actions': {
    header: 'Printers',
    description: 'Printers print a file from the computer',
    action: { title: 'action-1-title', url: 'action-1-url' },
    secondaryActions: [
      { title: 'action-2-title', url: 'action-2-url' },
      { title: 'action-3-title', url: 'action-3-url' },
      { title: 'action-4-title', url: 'action-4-url' },
    ],
  },
};

describe('Default Empty State', () => {
  testComponentSnapshotsWithFixtures(
    DefaultEmptyState,
    defaultEmptyStateFixtures
  );
});

const emptyStatePatternFixtures = {
  'icon, header and description are mandatory': {
    icon: 'printer',
    header: 'Printers',
    description: 'Printers print a file from the computer',
  },
  'should render description when given one as a text': {
    icon: 'printer',
    header: 'Printers',
    description: 'Printers print a file from the computer',
    documentation: 'This is a simple description',
  },
  'should render description when given one as JSX': {
    icon: 'printer',
    header: 'Printers',
    description: 'Printers print a file from the computer',
    documentation: (
      <div>
        This is my <b>description</b>.
      </div>
    ),
  },
  'should render main action when given title and url': {
    icon: 'printer',
    header: 'printers',
    description: 'printers print a file from the computer',
    action: (
      <PrimaryActionButton
        action={{ title: 'my title', url: 'https://somewhere.com' }}
      />
    ),
  },
  'should render main action when given title and onClick': {
    icon: 'printers',
    header: 'printers',
    description: 'printers print a file from the computer',
    action: (
      <PrimaryActionButton
        action={{ title: 'my title again', onClick: () => '' }}
      />
    ),
  },
  'should render secondary action when given one': {
    icon: 'printer',
    header: 'printers',
    description: 'printers print a file from the computer',
    secondaryActions: (
      <SecondaryActionButtons
        actions={[
          { title: 'x', url: 'some-url' },
          { title: 'y', url: 'random-url' },
        ]}
      />
    ),
  },
};

describe('Empty State Pattern', () => {
  testComponentSnapshotsWithFixtures(
    EmptyStatePattern,
    emptyStatePatternFixtures
  );
});
