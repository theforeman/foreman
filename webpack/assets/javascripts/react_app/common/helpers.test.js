import {
  translateArray,
  translateObject,
  propsToSnakeCase,
  propsToCamelCase,
} from './helpers';

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
