import {
  createInitialChosen,
  getAvailableToAdd,
  reorderChosen,
  chosenValues,
  addToChosen,
  removeFromChosen,
  normalizeSelectedValues,
} from '../helpers';

describe('OrderableDataList helpers', () => {
  const options = [
    { label: 'Harddisk', value: 'disk' },
    { label: 'Network', value: 'network' },
    { label: 'CD-ROM', value: 'cdrom' },
  ];

  describe('normalizeSelectedValues', () => {
    it('coerces symbol-like values to strings', () => {
      expect(normalizeSelectedValues(['network', 'disk'])).toEqual([
        'network',
        'disk',
      ]);
    });
  });

  describe('createInitialChosen', () => {
    it('preserves selected boot device order', () => {
      const chosen = createInitialChosen(options, ['network', 'disk']);

      expect(chosen).toEqual([
        { label: 'Network', value: 'network' },
        { label: 'Harddisk', value: 'disk' },
      ]);
    });
  });

  describe('getAvailableToAdd', () => {
    it('returns options not already in boot order', () => {
      const chosen = createInitialChosen(options, ['network', 'disk']);
      const available = getAvailableToAdd(options, chosen);

      expect(available).toEqual([{ label: 'CD-ROM', value: 'cdrom' }]);
    });
  });

  describe('reorderChosen', () => {
    it('moves an item within the list', () => {
      const chosen = createInitialChosen(options, ['network', 'disk', 'cdrom']);
      const reordered = reorderChosen(chosen, 2, 0);

      expect(chosenValues(reordered)).toEqual(['cdrom', 'network', 'disk']);
    });
  });

  describe('addToChosen', () => {
    it('appends a device to boot order', () => {
      const chosen = createInitialChosen(options, ['network']);
      const nextChosen = addToChosen(chosen, options[0]);

      expect(chosenValues(nextChosen)).toEqual(['network', 'disk']);
    });
  });

  describe('removeFromChosen', () => {
    it('removes a device from boot order', () => {
      const chosen = createInitialChosen(options, ['network', 'disk']);
      const nextChosen = removeFromChosen(chosen, 'network');

      expect(chosenValues(nextChosen)).toEqual(['disk']);
    });
  });
});
