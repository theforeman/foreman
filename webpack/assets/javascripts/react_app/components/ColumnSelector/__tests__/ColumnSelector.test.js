import React from 'react';
import ColumnSelector from '../ColumnSelector';
import { ColumnSelectorProps } from '../ColumnsSelector.fixtures';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

const fixtures = {
  'should render': ColumnSelectorProps,
};
describe('ColumnSelector', () => {
  const columnSelector = () => (
    <ColumnSelector {...ColumnSelectorProps} />
  );
  testComponentSnapshotsWithFixtures(columnSelector, fixtures);
});
