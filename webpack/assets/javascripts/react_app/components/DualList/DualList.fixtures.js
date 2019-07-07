export const id = 'some-id';

export const selectedItems = [
  { label: 'CentOS', value: 1 },
  { label: 'Fedora', value: 2 },
];

export const props = {
  items: [
    { label: 'CentOS', value: 1 },
    { label: 'Fedora', value: 2 },
    { label: 'RedHat', value: 3 },
    { label: 'Debian', value: 4 },
    { label: 'Ubuntu', value: 5 },
  ],
  selectedIDs: [1, 2],
  inputProps: { name: 'some-name', id: 'some-id' },
  label: 'some -label',
  id,
};

export const initialData = {
  id,
  selectedItems,
};

export const itemsChanged = {
  id,
  selectedItems,
};
