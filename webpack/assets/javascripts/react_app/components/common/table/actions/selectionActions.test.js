import { testActionSnapshotWithFixtures } from '@theforeman/test';
import {
  selectPage,
  selectAllRows,
  unselectAllRows,
  selectRow,
  unselectRow,
} from './selectionActions';

const tableID = 'some-table-id';
const fixtures = {
  'should selectPage and succeed': () =>
    selectPage(tableID, [{ id: 'some-id' }]),
  'should selectAllRows and succeed': () => selectAllRows(tableID),
  'should unselectAllRows and succeed': () => unselectAllRows(tableID),
  'should selectRow and succeed': () => selectRow(tableID, 'some-id'),
  'should unselectRow and succeed': () =>
    unselectRow(tableID, 'some-id', [{ id: 'some-id' }, { id: 'some-id2' }]),
};
describe('selectionActions', () => {
  testActionSnapshotWithFixtures(fixtures);
});
