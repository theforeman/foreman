import React from 'react';
import PropTypes from 'prop-types';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import {
  selectProps,
  ownComponentFieldProps,
  formAutocompleteDataProps,
} from '../FormField.fixtures';
import InputFactory, { registerInputComponent } from '../InputFactory';

const fixtures = {
  'renders text input': { type: 'text', name: 'a' },
  'renders DateTime input': { type: 'dateTime', name: 'a' },
  'renders AutoComplete': {
    type: 'autocomplete',
    ...formAutocompleteDataProps,
  },
  'renders Select': selectProps,
  'renders custom registered component': ownComponentFieldProps,
};

const Abc = props => <input type="hidden" id={props.id} name={props.name} />;
Abc.propTypes = {
  id: PropTypes.string,
  name: PropTypes.string,
};
Abc.defaultProps = {
  id: undefined,
  name: null,
};

describe('InputFactory', () => {
  describe('rendering', () => {
    registerInputComponent('ownInput', Abc);
    testComponentSnapshotsWithFixtures(InputFactory, fixtures);
  });
});
