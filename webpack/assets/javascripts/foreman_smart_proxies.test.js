import $ from 'jquery';

import './__mocks__/global_functions';
import { activateTooltips } from './foreman_tools';
import { activateLogsDataTable, expireLogs } from './foreman_smart_proxies';

jest.unmock('./foreman_smart_proxies');
jest.mock('jquery');

afterEach(() => {
  $.mockReset();
  $.ajax.mockReset();
});

describe('foreman_smart_proxies', () => {
  describe('activateLogsDataTable', () => {
    let mocks;
    const tableRootQuery = '#table-proxy-status-logs';

    beforeEach(() => {
      mocks = {};
      mocks.table = jest.fn();
      mocks.onFilter = jest.fn();
      mocks.onModal = jest.fn();
      mocks.jqueryFilter = { on: mocks.onFilter };

      $.mockReturnValueOnce({ DataTable: mocks.table })
        .mockReturnValueOnce(mocks.jqueryFilter)
        .mockReturnValueOnce({ on: mocks.onModal });

      activateLogsDataTable();
    });

    it('pick jquery element and initialize with DataTable', () => {
      expect($).toBeCalledWith(tableRootQuery);
      expect(mocks.table).toBeCalled();
    });

    it('initializes the filter select2 component', () => {
      expect($).toBeCalledWith('#logs-filter');
      expect(window.activate_select2).toBeCalledWith(mocks.jqueryFilter);
      expect(mocks.onFilter.mock.calls[0][0]).toBe('change');
    });

    it('initializes the modal window component', () => {
      expect($).toBeCalledWith('#logEntryModal');
      expect(mocks.onModal.mock.calls[0][0]).toBe('show.bs.modal');
    });

    it('activates tooltips', () => {
      expect(activateTooltips).toBeCalledWith(tableRootQuery);
    });
  });

  describe('expireLogs', () => {
    it('calls ajax three times', () => {
      const item = {
        getAttribute: jest.fn(urlType => `/${urlType}`),
      };

      expireLogs(item, 'fromSomething');

      expect($.ajax).toBeCalledTimes(3);
    });
  });
});
