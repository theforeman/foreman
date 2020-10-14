import React from 'react';
import { Provider } from 'react-redux';
import store from '../../../redux';
import DefaultEmptyState, { EmptyStatePattern } from './index';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';
import { props, action } from './EmptyStateFixtures';

const defaultEmptyStateFixtures = {
  'should render documentation when given a url': {
    ...props,
    action,
  },
  'should render secondary actions': {
    ...props,
    action,
    secondaryActions: [action],
  },
};

describe('Default Empty State', () => {
  testComponentSnapshotsWithFixtures(
    () => (
      <Provider store={store}>
        <DefaultEmptyState {...props} />
      </Provider>
    ),
    defaultEmptyStateFixtures
  );
});

const emptyStatePatternFixtures = {
  'should render with props': props,
};

describe('Empty State Pattern', () => {
  testComponentSnapshotsWithFixtures(
    EmptyStatePattern,
    emptyStatePatternFixtures
  );
});
