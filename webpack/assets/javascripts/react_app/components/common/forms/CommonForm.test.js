import React from 'react';
import { render, screen } from '@testing-library/react';
import { FieldLevelHelp } from 'patternfly-react';
import '@testing-library/jest-dom';

import CommonForm from './CommonForm';

describe('common Form', () => {
  it('displays a label field', () => {
    render(<CommonForm label="my label" />);

    expect(screen.getByText('my label')).toBeInTheDocument();
  });

  it('marks a required field with an asterisk', () => {
    render(<CommonForm label="my label" required />);

    expect(screen.getByText('my label *')).toBeInTheDocument();
  });

  it('displays validation errors when touched', () => {
    const { container } = render(
      <CommonForm label="my label" touched error="is required!" />
    );

    expect(screen.getByText('is required!')).toBeInTheDocument();
    expect(container.querySelector('.form-group')).toHaveClass('has-error');
  });

  it('does not display validation errors when not touched', () => {
    render(<CommonForm label="my label" error="is required!" />);

    expect(screen.queryByText('is required!')).not.toBeInTheDocument();
  });

  it('does not display validation errors when there are none', () => {
    const { container } = render(<CommonForm label="my label" />);

    expect(container.querySelector('.help-block')).not.toBeInTheDocument();
    expect(container.querySelector('.form-group')).not.toHaveClass('has-error');
  });

  it('accepts a customized input class', () => {
    const { container } = render(
      <CommonForm name="name" inputClassName="col-md-10" label="Name" />
    );

    expect(container.querySelector('.col-md-10')).toBeInTheDocument();
  });

  it('renders tooltip help', () => {
    const { container } = render(
      <CommonForm
        name="name"
        label="Required form field"
        required
        tooltipHelp={<FieldLevelHelp content="This is a helpful tooltip" />}
      />
    );

    expect(screen.getByText('Required form field *')).toBeInTheDocument();
    expect(container.querySelector('.pficon')).toBeInTheDocument();
  });
});
