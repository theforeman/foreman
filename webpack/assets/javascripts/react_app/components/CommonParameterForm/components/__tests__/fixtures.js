import { noop } from '../../../../common/helpers';

const valueFieldProps = {
  id: 'common_parameter_value',
  name: 'common_parameter[value]',
  css: 'form-control',
  onChange: noop,
};

export const booleanValueFixtures = {
  'when value = ""': { ...valueFieldProps, value: '' },
  'when value = true': { ...valueFieldProps, value: true },
  'when value = false': { ...valueFieldProps, value: false },
};

export const editorFixtures = {
  'with fullScreen': {
    ...valueFieldProps,
    value: 'something',
    mode: 'text',
    fullScreen: true,
  },
  'without fullScreen': {
    ...valueFieldProps,
    value: 'something',
    mode: 'text',
    fullScreen: false,
  },
};

export const numberValueFixtures = {
  default: { ...valueFieldProps, value: '123' },
};

export const stringValueFixtures = {
  'with fullScreen': {
    ...valueFieldProps,
    value: 'something',
    fullScreen: true,
  },
  'without fullScreen': {
    ...valueFieldProps,
    value: 'something',
    fullScreen: false,
  },
};

export const hiddenValueFieldFixtures = {
  'when hidden': {
    value: true,
    onChange: noop,
  },
  'when displayed': {
    value: false,
    onChange: noop,
  },
};

export const nameFieldFixtures = {
  default: { onChange: noop, value: 'something' },
};
export const typeFieldFixtures = {
  default: { selectedType: 'string', onChange: noop },
};

const valueParams = {
  onChange: noop,
  value: '',
  isMasked: false,
  selectedType: 'string',
};

export const valueFieldFixtures = {
  default: valueParams,
  'when is hidden': { ...valueParams, isMasked: true },
  'when selectedType = boolean': { ...valueParams, selectedType: 'boolean' },
  'when selectedType = integer': { ...valueParams, selectedType: 'integer' },
  'when selectedType = real': { ...valueParams, selectedType: 'real' },
  'when selectedType = array': { ...valueParams, selectedType: 'array' },
  'when selectedType = hash': { ...valueParams, selectedType: 'hash' },
  'when selectedType = yaml': { ...valueParams, selectedType: 'yaml' },
  'when selectedType = json': { ...valueParams, selectedType: 'json' },
};
