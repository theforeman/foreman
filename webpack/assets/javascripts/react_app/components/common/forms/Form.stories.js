import React, { useContext } from 'react';
import PropTypes from 'prop-types';
import { storiesOf } from '@storybook/react';
import { Grid, Row } from 'patternfly-react';
import { Formik } from 'formik';
import RadioButtonGroup from './RadioButtonGroup';
import FormField, { registerInputComponent, ControlContext } from './FormField';
import Form from './Form';
import OrderableSelect from './OrderableSelect';
import storeDecorator from '../../../../../../stories/storeDecorator';
import Story from '../../../../../../stories/components/Story';

import { yesNoOpts } from './__fixtures__/Form.fixtures';
import {
  textFieldWithHelpProps,
  dateTimeWithErrorProps,
  ownComponentFieldProps,
} from './FormField.fixtures';

const StoryForm = () => {
  return (
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
};

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

function CustomSelectWithContext(props) {
  const controlProps = useContext(ControlContext);
  return (
    <select id={controlProps.id} name={controlProps.name}>
      <option>{props.firstOption}</option>
    </select>
  );
}
CustomSelectWithContext.propTypes = {
  firstOption: PropTypes.string.isRequired,
};

storiesOf('Components/Form', module)
  .addDecorator(storeDecorator)
  .add('Radio Button Group', () => (
    <Story>
      <StoryForm />
    </Story>
  ))
  .add('FormField', () => (
    <Story>
      <Grid>
        <Row>
          <FormField {...textFieldWithHelpProps} />
        </Row>
        <Row>
          <FormField {...dateTimeWithErrorProps} />
        </Row>
        <Row>
          <FormField {...ownComponentFieldProps} />
        </Row>
        <Row>
          <FormField
            {...ownComponentFieldProps}
            label="Customly rendered field"
          >
            <CustomSelectWithContext firstOption="CustomlyRenderedInput" />
          </FormField>
        </Row>
      </Grid>
    </Story>
  ))
  .add('OrderableSelect', () => (
    <Story>
      <OrderableSelect
        name="orderable[select][]"
        options={yesNoOpts}
        id="orderable_select"
      />
    </Story>
  ));
