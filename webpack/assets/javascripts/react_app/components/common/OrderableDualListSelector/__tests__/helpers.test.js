import {
  appendUniqueOptions,
  chosenValues,
  createInitialLists,
  moveItems,
  namesToOptions,
  normalizeOptions,
  normalizeSelectedValues,
  optionsToNames,
  reorderChosen,
} from '../helpers';

describe('OrderableDualListSelector helpers', () => {
  const options = [
    { label: 'Harddisk', value: 'disk' },
    { label: 'Network', value: 'network' },
    { label: 'CD-ROM', value: 'cdrom' },
  ];

  describe('normalizeOptions', () => {
    it('converts string options to label/value objects', () => {
      expect(normalizeOptions(['role.a', 'role.b'])).toEqual([
        { label: 'role.a', value: 'role.a' },
        { label: 'role.b', value: 'role.b' },
      ]);
    });
  });

  describe('namesToOptions and optionsToNames', () => {
    it('converts between role names and option objects', () => {
      const optionObjects = namesToOptions(['role.a', 'role.b']);

      expect(optionObjects).toEqual([
        { label: 'role.a', value: 'role.a' },
        { label: 'role.b', value: 'role.b' },
      ]);
      expect(optionsToNames(optionObjects)).toEqual(['role.a', 'role.b']);
    });
  });

  describe('appendUniqueOptions', () => {
    it('does not duplicate options already present in the target list', () => {
      const chosen = [{ label: 'Network', value: 'network' }];
      const available = [
        { label: 'Network', value: 'network' },
        { label: 'CD-ROM', value: 'cdrom' },
      ];

      expect(appendUniqueOptions(chosen, available)).toEqual([
        { label: 'Network', value: 'network' },
        { label: 'CD-ROM', value: 'cdrom' },
      ]);
    });
  });

  describe('moveItems', () => {
    it('moves selected options without duplicating existing chosen values', () => {
      const available = [
        { label: 'Network', value: 'network' },
        { label: 'CD-ROM', value: 'cdrom' },
      ];
      const chosen = [{ label: 'Network', value: 'network' }];

      expect(moveItems(available, chosen, ['network', 'cdrom'])).toEqual([
        [],
        [
          { label: 'Network', value: 'network' },
          { label: 'CD-ROM', value: 'cdrom' },
        ],
      ]);
    });
  });

  describe('reorderChosen', () => {
    it('moves an option from source index to destination index', () => {
      const chosen = [
        { label: 'Network', value: 'network' },
        { label: 'Harddisk', value: 'disk' },
        { label: 'CD-ROM', value: 'cdrom' },
      ];

      expect(reorderChosen(chosen, 0, 2).map(option => option.value)).toEqual([
        'disk',
        'cdrom',
        'network',
      ]);
    });
  });

  describe('normalizeSelectedValues', () => {
    it('coerces values to strings', () => {
      expect(normalizeSelectedValues(['network', 'disk'])).toEqual([
        'network',
        'disk',
      ]);
      expect(normalizeSelectedValues('network')).toEqual(['network']);
      expect(normalizeSelectedValues(null)).toEqual([]);
    });
  });

  describe('createInitialLists', () => {
    it('splits options into available and chosen while preserving order', () => {
      const { available, chosen } = createInitialLists(options, [
        'network',
        'disk',
      ]);

      expect(chosen.map(option => option.value)).toEqual(['network', 'disk']);
      expect(available.map(option => option.value)).toEqual(['cdrom']);
    });

    it('accepts string options', () => {
      const { available, chosen } = createInitialLists(
        ['network', 'disk', 'cdrom'],
        ['network']
      );

      expect(chosen).toEqual([{ label: 'network', value: 'network' }]);
      expect(available.map(option => option.value)).toEqual(['disk', 'cdrom']);
    });

    it('puts all options in available when nothing is selected', () => {
      const { available, chosen } = createInitialLists(options, []);

      expect(chosen).toEqual([]);
      expect(available.map(option => option.value)).toEqual([
        'disk',
        'network',
        'cdrom',
      ]);
    });
  });

  describe('chosenValues', () => {
    it('returns ordered values from list options', () => {
      const chosen = [
        { label: 'Network', value: 'network' },
        { label: 'Harddisk', value: 'disk' },
      ];

      expect(chosenValues(chosen)).toEqual(['network', 'disk']);
    });
  });
});
