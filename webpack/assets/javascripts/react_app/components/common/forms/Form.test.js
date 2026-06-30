import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import Form from './Form';

describe('Form', () => {
  it('renders a form without an error alert', () => {
    const { container } = render(<Form />);

    expect(container.querySelector('form.form-horizontal')).toBeInTheDocument();
    expect(container.querySelector('.alert')).not.toBeInTheDocument();
  });

  it('displays one base error with the default title', () => {
    const { container } = render(
      <Form error={{ errorMsgs: ['invalid something'], severity: 'danger' }} />
    );

    expect(container.querySelector('.alert-danger')).toBeInTheDocument();
    expect(screen.getByText('Unable to save.')).toBeInTheDocument();
    expect(screen.getByText('invalid something')).toBeInTheDocument();
  });

  it('displays multiple base errors', () => {
    render(
      <Form
        error={{
          errorMsgs: ['invalid something', 'error too'],
          severity: 'danger',
        }}
      />
    );

    expect(screen.getByText('invalid something')).toBeInTheDocument();
    expect(screen.getByText('error too')).toBeInTheDocument();
  });

  it('accepts a base error title', () => {
    render(
      <Form
        error={{ errorMsgs: ['invalid something'], severity: 'danger' }}
        errorTitle="Oops"
      />
    );

    expect(screen.getByText('Oops')).toBeInTheDocument();
  });

  it('displays form errors as a warning', () => {
    const { container } = render(
      <Form
        error={{ errorMsgs: ['Do not feed the trolls'], severity: 'warning' }}
      />
    );

    expect(container.querySelector('.alert-warning')).toBeInTheDocument();
    expect(screen.getByText('Do not feed the trolls')).toBeInTheDocument();
  });
});
