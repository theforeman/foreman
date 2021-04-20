import React from 'react';
import PropTypes from 'prop-types';
import { Grid, Row } from 'patternfly-react';
import { number, text } from '@storybook/addon-knobs';
import { action } from '@storybook/addon-actions';
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
  counterProps,
  memoryProps,
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
  title: 'Components/Form',
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
      <Row>
        <FormField
          {...counterProps}
          min={number('CounterMinValue', 1)}
          max={number('CounterMaxValue', 16)}
          recommendedMaxValue={number('CounterRecommendedMaxValue', 10)}
          onChange={action('Counter value was changed')}
        />
      </Row>
      <Row>
        <FormField
          {...memoryProps}
          recommendedMaxValue={number('MemoryRecommendedMaxValue', 2048*1024*1024)}
          maxValue={number('MemoryMaxValue', 48000*1024*1024)}
          minValue={number('MemoryMinValue', 1024*1024)}
          onChange={action('Memory value was changed')}
        />
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
