import Normalizer from '../Normalizer';

describe('Normalize TimeseriesChart response', () => {
  it('should normalize an empty response', () => {
    expect(Normalizer([])).toEqual({
      columns: [],
    });
  });
  it('should normalize a response with single item', () => {
    const resp = [{
      label: 'item',
      data: [[10, 20], [20, 20], [30, 10]],
    }];
    expect(Normalizer(resp)).toEqual({
      x: 'time',
      columns: [['time', 10, 20, 30], ['item', 20, 20, 10]],
    });
  });
  it('should normalize a response with more than one item', () => {
    const resp = [{
      label: 'item1',
      data: [[10, 20], [12, 44]],
    },
    {
      label: 'item2',
      data: [[10, 0], [12, 0]],
    }];
    expect(Normalizer(resp)).toEqual({
      x: 'time',
      columns: [['time', 10, 12], ['item1', 20, 44], ['item2', 0, 0]],
    });
  });
  it('should normalize colors in a response', () => {
    const resp = [{
      label: 'item1',
      data: [[10, 20]],
      color: 'black',
    },
    {
      label: 'item2',
      data: [[10, 0]],
      color: 'green',
    }];
    expect(Normalizer(resp)).toEqual({
      x: 'time',
      columns: [['time', 10], ['item1', 20], ['item2', 0]],
      colors: { item1: 'black', item2: 'green' },
    });
  });
});
