import React from 'react';
import TestRenderer from 'react-test-renderer';
import DefaultEmptyState, { EmptyStatePattern } from './index';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const defaultEmptyStateFixtures = {
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
  // React.Fragment is rendered as <Unknown>:
  // https://github.com/facebook/jest/pull/5816
  // To fix this, I am using TestRenderer.create.
  // TODO: when jest-cli is upgraded to 23.0.0 move this to fixtures above.
  it('should render documentation when given a url', () => {
    expect(
      TestRenderer.create(
        <DefaultEmptyState
          header="Printers"
          description="Printers print a file from the computer"
          action={{ title: 'action-title', url: 'action-url' }}
          documentation={{ url: 'doc-url' }}
        />
      )
    ).toMatchSnapshot();
  });
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
  'should render main action when given one': {
    icon: 'printer',
    header: 'printers',
    description: 'printers print a file from the computer',
    action: <button>action-title</button>,
  },
  'should render secondary action when given one': {
    icon: 'printer',
    header: 'printers',
    description: 'printers print a file from the computer',
    secondaryActions: [
      <button key="y">action-y</button>,
      <button key="x">action-x</button>,
    ],
  },
};

describe('Empty State Pattern', () => {
  testComponentSnapshotsWithFixtures(
    EmptyStatePattern,
    emptyStatePatternFixtures
  );
});
