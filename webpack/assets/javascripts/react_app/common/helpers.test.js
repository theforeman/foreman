import {
  isoCompatibleDate,
  translateArray,
  translateObject,
} from './helpers';

describe('isoCompatibleDate', () => {
  it('converts strings to ISO compatible format', () => {
    const nonIsoDate = '2019-03-14 09:26:17 -0400';
    expect(isoCompatibleDate(nonIsoDate)).toMatchSnapshot();
  });

  it('ignores non-matching date strings', () => {
    const nonMatchingDate = '2019/03/14 09:26:17 -0400';
    expect(isoCompatibleDate(nonMatchingDate)).toMatchSnapshot();
  });

  it('preserves Date objects', () => {
    const preserved = new Date('2019-03-14T09:26:17-0400');
    expect(isoCompatibleDate(preserved)).toMatchSnapshot();
  });
});

describe('translateArray, translateObject', () => {
  const arr = ['Hello', 'There'];
  const obj = { first: 'Hello', second: 'There' };
  it('should translate Array', () => {
    expect(translateArray(arr)).toMatchSnapshot();
  });
  it('should translate Object', () => {
    expect(translateObject(obj)).toMatchSnapshot();
  });
});
