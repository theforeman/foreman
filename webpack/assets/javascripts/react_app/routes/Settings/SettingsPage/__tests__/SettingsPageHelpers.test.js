import { demodulize, stickGeneralFirst } from '../SettingsPageHelpers';

describe('SettingsPageHelpers', () => {
  it('should demodulize setting category', () => {
    expect(demodulize('Setting::Foo')).toBe('Foo');
  });

  it('should stick General category first', () => {
    const general = 'Setting::General';
    const categories = ['Foo', general, 'Bar', 'Setting::AAA'];
    expect(stickGeneralFirst(categories)[0]).toBe(general);
  });

  it('should not change order when general is absent', () => {
    const categories = ['Foo', 'Bar', 'Setting::AAA'];
    expect(stickGeneralFirst(categories)).toEqual(categories);
  });
});
