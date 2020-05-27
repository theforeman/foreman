import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Row } from 'patternfly-react';
import { Formik } from 'formik';
import RadioButtonGroup from './RadioButtonGroup';
import FormField from './FormField';
import { registerInputComponent } from './InputFactory';
import Form from './Form';
import OrderableSelect from './OrderableSelect';
import storeDecorator from '../../../../../../stories/storeDecorator';
import Story from '../../../../../../stories/components/Story';

import { yesNoOpts } from './__fixtures__/Form.fixtures';
import {
  textFieldWithHelpProps,
  selectProps,
  dateTimeWithErrorProps,
  ownComponentFieldProps,
} from './FormField.fixtures';

const StoryForm = () => (
  <Formik
    onSubmit={(values, actions) => {}}
    initialValues={{ hamburger: 'yes' }}
  >
    {formikProps => (
      <Form>
        <RadioButtonGroup
          name="hamburger"
          controlLabel="Would you like a hamburger?"
          radios={yesNoOpts}
        />
      </Form>
    )}
  </Formik>
);

function CustomSelect(props) {
  return (
    <select id={props.id} name={props.name}>
      <option>customInput</option>
    </select>
  );
}
CustomSelect.propTypes = {
  id: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
};
registerInputComponent('ownInput', CustomSelect);

export default {
  title: 'Components|Form',
  decorators: [storeDecorator],
};

export const radioButtonGroup = () => (
  <Story>
    <StoryForm />
  </Story>
);

export const formField = () => (
  <Story>
    <Grid>
      <Row>
        <FormField {...textFieldWithHelpProps} />
      </Row>
      <Row>
        <FormField {...selectProps} />
      </Row>
      <Row>
        <FormField {...dateTimeWithErrorProps} />
      </Row>
      <Row>
        <FormField {...ownComponentFieldProps} />
      </Row>
    </Grid>
  </Story>
);

formField.story = {
  name: 'FormField',
};

export const orderableSelect = () => (
  <Story>
    <OrderableSelect
      name="orderable[select][]"
      options={yesNoOpts}
      id="orderable_select"
    />
  </Story>
);

orderableSelect.story = {
  name: 'OrderableSelect',
};
