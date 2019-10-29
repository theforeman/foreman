import React from 'react';
import {
  testComponentSnapshotsWithFixtures,
  testSelectorsSnapshotWithFixtures,
} from 'react-redux-test-utils';
import * as Yup from 'yup';
import PropTypes from 'prop-types';

import ForemanForm, { prepareErrors, isInitialValid } from './ForemanForm';
import TextField from '../TextField';

const fixtures = {
  'render foreman form with fields': {
    submitForm: () => {},
    initialValues: {
      name: 'Charles',
      surname: 'Lindbergh',
    },
    validationSchema: Yup.object().shape({
      name: Yup.string().required('is required'),
      surname: Yup.string().min([3, 'is too short']),
    }),
    onCancel: () => {},
  },
};

const FormComponent = ({
  submitForm,
  initialValues,
  validationSchema,
  onCancel,
}) => (
  <ForemanForm
    onSubmit={(values, actions) => submitForm(values)}
    initialValues={initialValues}
    validationSchema={validationSchema}
    onCancel={onCancel}
  >
    <TextField name="name" type="text" required="true" label="name" />
    <TextField name="surname" type="text" label="surname" />
  </ForemanForm>
);

FormComponent.propTypes = {
  submitForm: PropTypes.func.isRequired,
  initialValues: PropTypes.object.isRequired,
  validationSchema: PropTypes.object.isRequired,
  onCancel: PropTypes.func.isRequired,
};

const basicSchema = Yup.object().shape({
  name: Yup.string().required('is required'),
});

const helperFixtures = {
  'should format errors': () =>
    prepareErrors({
      name: ['is already taken', 'is too short'],
      email: ['is not a valid format'],
      phone: ['is too long'],
    }),
  'should recognize valid initial values': () =>
    isInitialValid({
      validationSchema: basicSchema,
      initialValues: { name: 'George' },
    }),
  'should recognize invalid initial values': () =>
    isInitialValid({ validationSchema: basicSchema, initialValues: {} }),
};

describe('ForemanForm', () => {
  testComponentSnapshotsWithFixtures(FormComponent, fixtures);
});

describe('Foreman form helper functions', () =>
  testSelectorsSnapshotWithFixtures(helperFixtures));
