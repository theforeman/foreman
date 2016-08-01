jest.unmock('./c3DonutChartService');
jest.mock('c3');

import service from './c3DonutChartService';
import $ from 'jquery';
import c3 from 'c3';

let columns, selector, dataEventHandlers;

beforeEach(() => {
  columns = [
    ['Fedora 21', 3],
    ['Debian 8', 1]
  ];
  dataEventHandlers = undefined;
  $.fn.pfDonutTooltipContents = jest.fn();
  $.fn.pfSetDonutChartTitle = jest.fn();
});

describe('service', () => {
  describe('generate', () => {
    it('call c3.generate', () => {
      const config = service.getDonutConfig(columns, selector, dataEventHandlers);

      c3.generate = jest.fn();

      service.generate(config);

      expect(c3.generate).toBeCalledWith(config);
    });
    it('does not call c3.generate when there is no data', () => {
      const nodata = service.getDonutConfig([], selector, dataEventHandlers);

      c3.generate = jest.fn();

      service.generate(nodata);

      expect(c3.generate.mock.calls.length).toBe(0);
    });
  });
  describe('donut config', () => {
    it('applies data handlers if necessary', () => {
      const config = service.getDonutConfig(columns, selector, {
        onclick: function () {
        }
      });

      expect(config.data.onclick).toBeDefined();
      expect(config.donut.width).toBe(service.enums.WIDTH.SMALL);
    });
    it('large donut config', () => {
      const config = service.getLargeDonutConfig(columns, selector);

      expect(config.donut.width).toBe(service.enums.WIDTH.LARGE);
      expect(config.size).toBe(service.enums.SIZE.LARGE);
      expect(config.data.onclick).toBeUndefined();
    });
  });
});
