import forceSingleton from './forceSingleton';

describe('forceSingleton', () => {
  it('should force a single instance', () => {
    const createInstance = () => ({});

    expect(forceSingleton('key1', createInstance)).toBe(
      forceSingleton('key1', createInstance)
    );
    expect(forceSingleton('key1', createInstance)).not.toBe(
      forceSingleton('key2', createInstance)
    );
    expect(forceSingleton('key2', createInstance)).toBe(
      forceSingleton('key2', createInstance)
    );
  });
});
