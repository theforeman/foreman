import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Formik } from 'formik';
import '@testing-library/jest-dom';
import { DateTimeProps, DateTimeWithRequireAndInfo } from './DateTime.fixtures';
import DateTime from './DateTime';

// A flat (bracket-free) field name so Formik stores it as a top-level key we
// can read back; the fixture's `foo[bar][4][value]` name is parsed by Formik as
// a nested path, which would defeat a simple values[name] lookup.
const FIELD_NAME = 'dateValue';
const functionalProps = {
  ...DateTimeProps,
  inputProps: { name: FIELD_NAME },
};

const renderDateTime = props =>
  render(
    <Formik initialValues={{}} onSubmit={() => {}}>
      <DateTime {...props} />
    </Formik>
  );

// same as renderDateTime, but surfaces the Formik field value so tests can
// assert that interactions actually propagate up through setFieldValue
const renderWithFormValue = props =>
  render(
    <Formik initialValues={{}} onSubmit={() => {}}>
      {({ values }) => (
        <>
          <DateTime {...props} />
          <output data-testid="form-value">{values[FIELD_NAME] || ''}</output>
        </>
      )}
    </Formik>
  );

describe('DateTime', () => {
  it('renders the labeled date input', () => {
    renderDateTime(DateTimeProps);

    expect(screen.getByText('some-label')).toBeInTheDocument();
    expect(
      screen.getByRole('textbox', { name: 'date and time picker' })
    ).toBeInTheDocument();
    // no required marker and no info help by default. The field-level help
    // button lives inside the label, so it would take the label text as its
    // accessible name; with no info there is no such button.
    expect(screen.queryByText('some-label *')).not.toBeInTheDocument();
    expect(
      screen.queryByRole('button', { name: 'some-label' })
    ).not.toBeInTheDocument();
  });

  it('renders the required marker and info help', () => {
    renderDateTime(DateTimeWithRequireAndInfo);

    // required adds an asterisk to the label
    expect(screen.getByText('some-label *')).toBeInTheDocument();
    // info renders a field-level help button, nested in the label so it takes
    // the label text as its accessible name
    expect(
      screen.getByRole('button', { name: 'some-label *' })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('textbox', { name: 'date and time picker' })
    ).toBeInTheDocument();
  });

  it('updates the input as the user types and propagates the value to the form', async () => {
    renderWithFormValue(functionalProps);

    const input = screen.getByRole('textbox', { name: 'date and time picker' });

    await userEvent.clear(input);
    await userEvent.type(input, '2020-05-06 10:30');

    // the controlled input reflects exactly what was typed
    expect(input).toHaveValue('2020-05-06 10:30');
    // and the value flows up to Formik via the onChange -> setFieldValue wiring
    await waitFor(() =>
      expect(screen.getByTestId('form-value')).toHaveTextContent(
        '2020-05-06 10:30'
      )
    );
  });

  it('clears the field value when the input is emptied', async () => {
    renderWithFormValue(functionalProps);

    const input = screen.getByRole('textbox', { name: 'date and time picker' });
    // starts populated from the fixture's date value, which propagates on mount
    expect(input).not.toHaveValue('');
    await waitFor(() =>
      expect(screen.getByTestId('form-value')).not.toBeEmptyDOMElement()
    );

    await userEvent.clear(input);

    expect(input).toHaveValue('');
    await waitFor(() =>
      expect(screen.getByTestId('form-value')).toBeEmptyDOMElement()
    );
  });
});
