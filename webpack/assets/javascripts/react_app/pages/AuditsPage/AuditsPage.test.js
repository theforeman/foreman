import React from 'react';
import { shallow } from 'enzyme';

import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';
import AuditsPage from './AuditsPage';
import { AuditsProps } from '../../components/AuditsList/__tests__/AuditsList.fixtures';
import { paginationMock } from '../../components/Pagination/Pagination.fixtures';
import { SearchBarProps } from '../../components/SearchBar/SearchBar.fixtures';

const auditsPageFixtures = {
  'render audits page': {
    data: {
      audits: AuditsProps,
      pagination: paginationMock.data,
      searchable: true,
    },
  },
};

jest.mock('../../../../../../package.json', () => ({
  version: '1.2.3.4',
}));

describe('AuditsPage', () => {
  describe('rendering', () =>
    testComponentSnapshotsWithFixtures(AuditsPage, auditsPageFixtures));

  describe('pagination is rendered', () => {
    const component = shallow(
      <AuditsPage
        data={{
          audits: AuditsProps,
          pagination: paginationMock.data,
          searchProps: SearchBarProps,
          searchable: false,
        }}
      />
    ).dive();

    expect(component.exists('#pagination')).toBeTruthy();
  });
});
