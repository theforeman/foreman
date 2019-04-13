import React from 'react';
import PropTypes from 'prop-types';
import { shallow } from 'enzyme';
import toJson from 'enzyme-to-json';
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import {
  dateTimeWithErrorProps,
  textFieldWithHelpProps,
  ownComponentFieldProps,
} from '../FormField.fixtures';
import FormField, { registerInputComponent } from '../FormField';

const fixtures = {
  'renders text input': { type: 'text', name: 'a' },
  'renders Date input': { type: 'date', name: 'a' },
  'renders Time input': { type: 'time', name: 'a' },
  'renders DateTime input': { type: 'dateTime', name: 'a' },
  'renders text complex options and help': textFieldWithHelpProps,
  'renders DateTime complex options and error': dateTimeWithErrorProps,
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

describe('FormField', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(FormField, fixtures);
  });

  describe('register own component', () => {
    it('renders registered component', () => {
      registerInputComponent('ownInput', Abc);

      expect(
        toJson(shallow(<FormField {...ownComponentFieldProps} />))
      ).toMatchSnapshot();
    });
  });
});
