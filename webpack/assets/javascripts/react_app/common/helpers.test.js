import {
  isoCompatibleDate,
  translateArray,
  translateObject,
  propsToSnakeCase,
  propsToCamelCase,
  deepPropsToSnakeCase,
  deepPropsToCamelCase,
  removeLastSlashFromPath,
  stringIsPositiveNumber,
  formatDate,
  formatDateTime,
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

describe('propsToCamelCase, propsToSnakeCase', () => {
  const snakeObj = { hello_world: 'hello', test_obj: 'test' };
  const camelObj = { helloWorld: 'hello', testObj: 'test' };

  it('should transform keys to camel case', () => {
    expect(propsToCamelCase(snakeObj)).toEqual(camelObj);
  });

  it('should transform keys to snake case', () => {
    expect(propsToSnakeCase(camelObj)).toEqual(snakeObj);
  });
});

describe('deepPropsToCamelCase, deepPropsToSnakeCase', () => {
  const snakeObj = {
    hello_world: 'hello',
    test_obj: [
      { blue_moon: 'blue moon' },
      { red_sun: 'red sun' },
      { clear_sky: ['no clouds here'] },
    ],
    bat_man: null,
    cat_man: undefined,
    frog_man: '',
    dog_man: 0,
    spider_man: {
      global_net: 'bar',
    },
  };
  const camelObj = {
    helloWorld: 'hello',
    testObj: [
      { blueMoon: 'blue moon' },
      { redSun: 'red sun' },
      { clearSky: ['no clouds here'] },
    ],
    batMan: null,
    catMan: undefined,
    frogMan: '',
    dogMan: 0,
    spiderMan: {
      globalNet: 'bar',
    },
  };

  it('should transform deep keys to camel case', () => {
    expect(deepPropsToCamelCase(snakeObj)).toEqual(camelObj);
  });

  it('should transform deep keys to snake case', () => {
    expect(deepPropsToSnakeCase(camelObj)).toEqual(snakeObj);
  });
});

describe('removeLastSlashFromPath', () => {
  const pathWithSlash = 'example.com/';
  const pathWithoutSlash = 'example.com';
  it('should remove the last Slash', () => {
    expect(removeLastSlashFromPath(pathWithSlash)).toBe('example.com');
  });
  it('should not change the path', () => {
    expect(removeLastSlashFromPath(pathWithoutSlash)).toBe('example.com');
  });
});

describe('stringIsPositiveNumber', () => {
  it('should return true on positive number', () => {
    expect(stringIsPositiveNumber('1')).toBeTruthy();
  });
  it('should return false on negative number', () => {
    expect(stringIsPositiveNumber('-1')).toBeFalsy();
  });
  it('should return false on a word', () => {
    expect(stringIsPositiveNumber('number')).toBeFalsy();
  });
});

describe('formatDate', () => {
  it('should return date string', () => {
    const date = new Date('2020-03-06 14:00');
    expect(formatDate(date)).toEqual('2020-03-06');
  });
});

describe('formatDateTime', () => {
  it('should return datetime string', () => {
    const date = new Date('2020-03-06 14:00');
    expect(formatDateTime(date)).toEqual('2020-03-06 14:00:00');
  });
});
