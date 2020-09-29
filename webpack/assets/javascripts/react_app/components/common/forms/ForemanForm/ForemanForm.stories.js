import React from 'react';
import * as Yup from 'yup';
import PropTypes from 'prop-types';

import ForemanForm from '.';
import TextField from '../TextField';
import RadioButtonGroup from '../RadioButtonGroup';
import Story from '../../../../../../../stories/components/Story';

const DisplayFormikState = props => (
  <div style={{ margin: '1rem 0' }}>
    <pre
      style={{
        background: '#f6f8fa',
        padding: '.5rem',
      }}
    >
      <strong>props</strong> = {JSON.stringify(props, null, 2)}
    </pre>
  </div>
);

const fixtures = {
  submitForm: () => {},
  initialValues: {
    nickname: 'El Duderino',
    weapon: 'hammer',
    vegetarian: false,
  },
  validationSchema: Yup.object().shape({
    nickname: Yup.string().required('is required'),
  }),
  onCancel: () => {},
};

const radios = [
  { label: 'Hammer', value: 'hammer' },
  { label: 'Nail Gun', value: 'nailgun' },
  { label: 'Wrecking Ball', value: 'wreckingball' },
];

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
    <TextField name="nickname" type="text" required="true" label="Nickname" />
    <RadioButtonGroup
      name="weapon"
      controlLabel="Preferred weapon"
      radios={radios}
    />
    <TextField name="vegetarian" type="checkbox" label="Are you vegetarian?" />
    <DisplayFormikState />
  </ForemanForm>
);

FormComponent.propTypes = {
  submitForm: PropTypes.func.isRequired,
  initialValues: PropTypes.object.isRequired,
  validationSchema: PropTypes.object.isRequired,
  onCancel: PropTypes.func.isRequired,
};

export default {
  title: 'Components|Foreman Form',
};

export const basicForemanForm = () => (
  <Story>
    <FormComponent {...fixtures} />
  </Story>
);
