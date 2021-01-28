import {
  arraySelection,
  valueToString,
  defaultToString,
} from '../SettingsTableHelpers';

import {
  withArraySelection,
  withHashSelection,
  boolSetting,
  arraySetting,
  timezoneSetting,
  httpProxySetting,
} from '../../SettingRecords/__tests__/SettingRecords.fixtures';

const array = [
  {
    label: 'Select an owner',
    value: null,
  },
  {
    groupLabel: 'Users',
    children: [
      { label: 'canned_admin', value: '13-Users' },
      { label: 'user', value: '19-Users' },
      { label: 'viewer', value: '27-Users' },
      { label: 'admin', value: '4-Users' },
    ],
  },
  {
    groupLabel: 'Usergroups',
    children: [
      { label: 'basic broup', value: '1-Usergroups' },
      { label: 'view hosts group', value: '2-Usergroups' },
    ],
  },
];

describe('SettingsTableHelpers', () => {
  describe('arraySelection', () => {
    it('should return array selection if present', () => {
      expect(arraySelection(withArraySelection)).toEqual(array);
    });

    it('should return null if array selection absent', () =>
      expect(arraySelection(withHashSelection)).toBeFalsy());
  });

  describe('valueToString', () => {
    it('should correctly format boolean value', () =>
      expect(valueToString(boolSetting)).toBe('Yes'));

    it('should correctly format array value', () =>
      expect(valueToString(arraySetting)).toBe('[localhost, 127.0.0.1]'));

    it('should correctly format array selection value', () =>
      expect(valueToString(withArraySelection)).toBe('view hosts group'));

    it('should correctly format empty value', () =>
      expect(valueToString({ default: 'random', value: null })).toBe('Empty'));

    it('should correctly format text value', () =>
      expect(valueToString({ default: 'random', value: 'value' })).toBe(
        'value'
      ));
    it('should correctly format hash selection value', () =>
      expect(valueToString(timezoneSetting)).toBe('(GMT +07:00) Bangkok'));
    it('should correctly format array selection value with single group', () =>
      expect(valueToString(httpProxySetting)).toBe('bar (https://bar.com)'));
  });

  describe('defaultToString', () => {
    it('should correctly format boolean value', () =>
      expect(defaultToString(boolSetting)).toBe('No'));

    it('should correctly format array value', () =>
      expect(defaultToString(arraySetting)).toBe('[]'));

    it('should correctly format array selection value', () =>
      expect(defaultToString(withArraySelection)).toBe('admin'));

    it('should correctly format empty value', () =>
      expect(defaultToString({ default: null, value: 'random' })).toBe(
        'Not set'
      ));

    it('should correctly format text value', () =>
      expect(defaultToString({ default: 'random', value: 'value' })).toBe(
        'random'
      ));
  });
});
