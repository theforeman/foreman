import { getSelectionController } from './selection';
import {
  selectRow,
  selectPage,
  unselectAllRows,
  unselectRow,
} from '../actions/selectionActions';

jest.mock('../actions/selectionActions');
const selectPageMock = 'selectPageMock';
const selectRowMock = 'selectRowMock';
const unselectRowMock = 'unselectRowMock';
const unselectAllRowsMock = 'unselectAllRowsMock';

selectRow.mockImplementation(() => selectRowMock);
selectPage.mockImplementation(() => selectPageMock);
unselectAllRows.mockImplementation(() => unselectAllRowsMock);
unselectRow.mockImplementation(() => unselectRowMock);

describe('getSelectionController', () => {
  const dispatch = jest.fn();

  beforeEach(() => dispatch.mockClear());
  const rows = [1, 2, 3];
  const selectedRows = [1];
  it('Should return a selectionController allRowsSelected:false', () => {
    const allRowsSelected = false;
    const selectCtrl = getSelectionController({
      allRowsSelected,
      rows,
      selectedRows,
      dispatch,
    });
    expect(selectCtrl.allRowsSelected).toBe(allRowsSelected);
    expect(selectCtrl.allPageSelected()).toBe(false);

    expect(selectCtrl.isSelected({ rowData: { id: 1 } })).toBe(true);
    expect(selectCtrl.isSelected({ rowData: { id: 2 } })).toBe(false);

    selectCtrl.selectPage();
    expect(dispatch).toBeCalledWith(selectPageMock);

    selectCtrl.selectRow({ rowData: { id: 2 } });
    expect(dispatch).toBeCalledWith(selectRowMock);

    selectCtrl.selectRow({ rowData: { id: 1 } });
    expect(dispatch).toBeCalledWith(unselectRowMock);
  });

  it('Should return a selectionController allRowsSelected:true', () => {
    const allRowsSelected = true;
    const selectCtrl = getSelectionController({
      allRowsSelected,
      rows,
      selectedRows,
      dispatch,
    });
    expect(selectCtrl.allRowsSelected).toBe(allRowsSelected);
    expect(selectCtrl.allPageSelected()).toBe(true);

    expect(selectCtrl.isSelected({ rowData: { id: 1 } })).toBe(true);
    expect(selectCtrl.isSelected({ rowData: { id: 2 } })).toBe(true);

    selectCtrl.selectPage();
    expect(dispatch).toBeCalledWith(unselectAllRowsMock);

    selectCtrl.selectRow({ rowData: { id: 2 } });
    expect(dispatch).toBeCalledWith(unselectRowMock);

    selectCtrl.selectRow({ rowData: { id: 1 } });
    expect(dispatch).toBeCalledWith(unselectRowMock);
  });
});
