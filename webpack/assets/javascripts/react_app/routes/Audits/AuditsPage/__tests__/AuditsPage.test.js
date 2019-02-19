import React from 'react';
import { shallow } from 'enzyme';

import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import AuditsPage from '../AuditsPage';
import { auditsPageProps } from '../AuditsPage.fixtures';

const auditsPageFixtures = {
  'render audits page': auditsPageProps,
  'render loading audits page': {
    ...auditsPageProps,
    showMessage: false,
    audits: [],
  },
  'render audits page w/empty audits': {
    ...auditsPageProps,
    showMessage: true,
    message: { type: 'empty', text: 'no audits' },
  },
  'render audits page w/error': {
    ...auditsPageProps,
    showMessage: true,
    message: { type: 'error', text: 'some-error' },
  },
};

describe('AuditsPage', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(AuditsPage, auditsPageFixtures));

  describe('pagination is rendered', () => {
    const fetchAudits = jest.fn();

    const component = shallow(
      <AuditsPage {...auditsPageProps} fetchAudits={fetchAudits} />
    ).dive();
    expect(component.exists('#pagination')).toBeTruthy();
  });
});
