import React from 'react';
import { render, screen } from '@testing-library/react';
import { Formik } from 'formik';
import '@testing-library/jest-dom';

import RadioButtonGroup from './RadioButtonGroup';

const radios = [
  { label: 'A', checked: true, value: 'A' },
  { label: 'B', checked: false, value: 'B' },
];

const renderGroup = props =>
  render(
    <Formik initialValues={{ RadioButtonGroupTest: 'A' }} onSubmit={() => {}}>
      <RadioButtonGroup
        name="RadioButtonGroupTest"
        controlLabel="RadioButtonGroupLabel"
        radios={radios}
        {...props}
      />
    </Formik>
  );

describe('radio button group', () => {
  it('renders a labeled group with one radio per item', () => {
    renderGroup();

    expect(screen.getByText('RadioButtonGroupLabel')).toBeInTheDocument();
    expect(screen.getAllByRole('radio')).toHaveLength(2);

    // the radio matching the form value is selected
    expect(screen.getByRole('radio', { name: 'A' })).toBeChecked();
    expect(screen.getByRole('radio', { name: 'B' })).not.toBeChecked();
  });

  it('renders disabled radios when disabled', () => {
    renderGroup({ disabled: true });

    screen.getAllByRole('radio').forEach(radio => {
      expect(radio).toBeDisabled();
    });
  });
});
