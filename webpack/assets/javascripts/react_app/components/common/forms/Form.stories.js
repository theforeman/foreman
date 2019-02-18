import React from '@theforeman/vendor/react';
import { storiesOf } from '@storybook/react';
import { reduxForm } from '@theforeman/vendor/redux-form';
import { connect } from '@theforeman/vendor/react-redux';

import RadioButtonGroup from './RadioButtonGroup';
import Form from './Form';
import storeDecorator from '../../../../../../stories/storeDecorator';
import Story from '../../../../../../stories/components/Story';

const formName = 'storybookForm';

const StoryForm = () => {
  const radios = [
    {
      label: 'Yes',
      value: 'yes',
    },
    {
      label: 'No',
      value: 'no',
    },
    {
      label: 'Do Not Know',
      value: 'dnk',
    },
  ];

  return (
    <Form>
      <RadioButtonGroup
        name="hamburger"
        controlLabel="Would you like a hamburger?"
        radios={radios}
      />
    </Form>
  );
};

const storyForm = reduxForm({ form: formName })(StoryForm);
const ConnectedForm = connect(
  null,
  () => {}
)(storyForm);

storiesOf('Components/Form', module)
  .addDecorator(storeDecorator)
  .add('Radio Button Group', () => (
    <Story>
      <ConnectedForm />
    </Story>
  ));
