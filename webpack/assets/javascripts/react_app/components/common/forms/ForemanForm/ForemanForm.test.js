import React from 'react';
import { testComponentSnapshotsWithFixtures } from 'react-redux-test-utils';
import * as Yup from 'yup';
import PropTypes from 'prop-types';

import ForemanForm from '.';
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

describe('ForemanForm', () => {
  testComponentSnapshotsWithFixtures(FormComponent, fixtures);
});
