jest.unmock('./c3DonutService');
jest.mock('c3');

import service from './c3DonutService';

let columns, selector;

beforeEach(() => {
  columns = [
    ['Fedora 21', 3],
    ['Debian 8', 1]
  ];
});

describe('service', () => {
  describe('donut config', () => {
    it('large donut config', () => {
      const config = service.getLargeDonutConfig(columns, selector);

      expect(config.donut.width).toBe(service.enums.WIDTH.LARGE);
      expect(config.size).toBe(service.enums.SIZE.LARGE);
      expect(config.data.onclick).toBeUndefined();
    });
  });
});
