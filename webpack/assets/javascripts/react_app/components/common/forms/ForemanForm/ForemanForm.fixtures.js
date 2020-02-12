import React from 'react';
import PropTypes from 'prop-types';
import * as Yup from 'yup';

import TextField from '../TextField';
import ForemanForm from './ForemanForm';

export const initialValues = {
  name: 'Charles',
  surname: 'Lindbergh',
};

export const validationSchema = Yup.object().shape({
  name: Yup.string().required('is required'),
  surname: Yup.string().min([3, 'is too short']),
});

export const FormComponent = ({ submitForm, initValues, schema, onCancel }) => (
  <ForemanForm
    onSubmit={(values, actions) => submitForm(values)}
    initialValues={initValues}
    validationSchema={schema}
    onCancel={onCancel}
  >
    <TextField name="name" type="text" required="true" label="name" />
    <TextField name="surname" type="text" label="surname" />
  </ForemanForm>
);

FormComponent.propTypes = {
  submitForm: PropTypes.func.isRequired,
  initValues: PropTypes.object.isRequired,
  schema: PropTypes.object,
  onCancel: PropTypes.func.isRequired,
};

FormComponent.defaultProps = {
  schema: undefined,
};
