import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import * as Yup from 'yup';

import { prepareErrors } from '../../../../redux/actions/common/forms';
import { isInitialValid } from './ForemanForm';
import {
  initialValues,
  FormComponent,
  validationSchema,
} from './ForemanForm.fixtures';

describe('ForemanForm', () => {
  it('renders the form fields with their initial values', () => {
    const { container } = render(
      <FormComponent
        submitForm={() => {}}
        initValues={initialValues}
        schema={validationSchema}
        onCancel={() => {}}
      />
    );

    // a field per child, populated from the initial values
    expect(container.querySelector('input[name="name"]')).toHaveValue(
      'Charles'
    );
    expect(container.querySelector('input[name="surname"]')).toHaveValue(
      'Lindbergh'
    );
    // the required field's label carries an asterisk
    expect(screen.getByText('name *')).toBeInTheDocument();
    expect(screen.getByText('surname')).toBeInTheDocument();
    // the form renders submit and cancel actions
    expect(screen.getByRole('button', { name: 'Submit' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeInTheDocument();
  });
});

describe('Foreman form helper functions', () => {
  const basicSchema = Yup.object().shape({
    name: Yup.string().required('is required'),
  });

  it('formats errors', () => {
    expect(
      prepareErrors({
        errors: {
          name: ['is already taken', 'is too short'],
          email: ['is not a valid format'],
          phone: ['is too long'],
        },
      })
    ).toEqual({
      _error: undefined,
      errors: {
        name: ['is already taken', 'is too short'],
        email: ['is not a valid format'],
        phone: ['is too long'],
      },
    });
  });

  it('recognizes valid initial values', () => {
    expect(
      isInitialValid({
        validationSchema: basicSchema,
        initialValues: { name: 'George' },
      })
    ).toBe(true);
  });

  it('recognizes invalid initial values', () => {
    expect(
      isInitialValid({ validationSchema: basicSchema, initialValues: {} })
    ).toBe(false);
  });
});
