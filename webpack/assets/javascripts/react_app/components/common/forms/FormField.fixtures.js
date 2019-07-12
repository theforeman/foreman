export const textFieldWithHelpProps = {
  type: 'text',
  id: 'text-field',
  label: 'textField',
  labelHelp: 'This is more helpful text',
  name: 'group[textfield]',
};

export const dateTimeWithErrorProps = {
  type: 'dateTime',
  id: 'date-time',
  label: 'DateTime with error',
  name: 'group[datetime]',
  value: new Date('1991-01-01T01:12:01Z'),
  error: 'can not be in the past',
};

export const ownComponentFieldProps = {
  type: 'ownInput',
  id: 'own-field',
  label: 'ownField',
  name: 'group[ownfield]',
};

export const formAutocompleteDataProps = {
  controller: 'bookmarks',
  url: 'bookmarks/auto_complete',
  disabled: false,
  useKeyShortcuts: false,
  searchQuery: '',
  name: 'Filter[search]',
  id: 'form-search',
};
