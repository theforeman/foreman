import { sortControllerFactory } from './index';

describe('sortControllerFactory', () => {
  it('should return a sortController', () => {
    const by = 'name';
    const order = 'DESC';
    const sortCtrl = sortControllerFactory(jest.fn(), by, order);
    expect(sortCtrl.property).toBe(by);
    expect(sortCtrl.order).toBe(order);
  });

  it('should call apiCall when apply', () => {
    const apiCall = jest.fn();
    const sortCtrl = sortControllerFactory(apiCall, '', '');
    sortCtrl.apply('nickname', 'ASC');
    expect(apiCall).toBeCalledWith({ order: 'nickname ASC' });
  });
});
