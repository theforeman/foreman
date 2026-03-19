import React from 'react';
import { createMemoryHistory } from 'history';
import { Router } from 'react-router-dom';
import { render, fireEvent, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';

import ModelForm from './ModelForm';
import { MODELS_PATH } from './constants';

jest.mock('@patternfly/react-core', () => {
  const ReactLib = require('react');

  const Form = ({ children, onSubmit, id }) => (
    <form onSubmit={onSubmit} id={id}>
      {children}
    </form>
  );

  const FormGroup = ({ label, children }) => (
    <div>
      {label ? <label>{label}</label> : null}
      {ReactLib.Children.map(children, child =>
        ReactLib.isValidElement(child)
          ? ReactLib.cloneElement(child, { 'aria-label': label })
          : child
      )}
    </div>
  );

  const TextInput = ({
    id,
    name,
    type,
    required,
    value,
    onChange,
    isDisabled,
    'aria-label': ariaLabel,
  }) => (
    <input
      id={id}
      name={name}
      type={type}
      required={required}
      value={value}
      onChange={onChange}
      disabled={isDisabled}
      aria-label={ariaLabel}
    />
  );

  const TextArea = ({
    id,
    name,
    rows,
    value,
    onChange,
    isDisabled,
    'aria-label': ariaLabel,
  }) => (
    <textarea
      id={id}
      name={name}
      rows={rows}
      value={value}
      onChange={onChange}
      disabled={isDisabled}
      aria-label={ariaLabel}
    />
  );

  const ActionGroup = ({ children }) => <div>{children}</div>;

  const Button = ({ children, isDisabled, type, onClick }) => (
    <button type={type || 'button'} disabled={isDisabled} onClick={onClick}>
      {children}
    </button>
  );

  return { Form, FormGroup, TextInput, TextArea, ActionGroup, Button };
});

jest.mock('../../components/common/LabelIcon', () => () => null);

const defaultInitialValues = {
  name: '',
  hardware_model: '',
  vendor_class: '',
  info: '',
};

const buildProps = overrides => ({
  initialValues: defaultInitialValues,
  handleSubmit: jest.fn(),
  isSubmitting: false,
  ...overrides,
});

const renderModelForm = propsOverrides => {
  const history = createMemoryHistory({
    initialEntries: ['/models/new'],
  });
  const utils = render(
    <Router history={history}>
      <ModelForm {...buildProps(propsOverrides)} />
    </Router>
  );
  return { ...utils, history };
};

describe('ModelForm', () => {
  it('renders initial values', () => {
    renderModelForm({
      initialValues: {
        name: 'PowerEdge R760',
        hardware_model: 'sun4u',
        vendor_class: 'SUNW,Sun-Fire-V490',
        info: 'Requires custom BIOS setup',
      },
    });

    expect(screen.getByLabelText('Name')).toHaveValue('PowerEdge R760');
    expect(screen.getByLabelText('Hardware model')).toHaveValue('sun4u');
    expect(screen.getByLabelText('Vendor class')).toHaveValue(
      'SUNW,Sun-Fire-V490'
    );
    expect(screen.getByLabelText('Info')).toHaveValue(
      'Requires custom BIOS setup'
    );
  });

  it('disables submit when required name is blank', () => {
    renderModelForm({
      initialValues: {
        ...defaultInitialValues,
        name: '   ',
      },
    });

    expect(screen.getByRole('button', { name: 'Submit' })).toBeDisabled();
  });

  it('disables submit when creating with undefined name', () => {
    renderModelForm({
      initialValues: {
        ...defaultInitialValues,
        name: undefined,
      },
    });

    expect(screen.getByRole('button', { name: 'Submit' })).toBeDisabled();
  });

  it('disables submit when update clears name to empty', () => {
    renderModelForm({
      initialValues: {
        ...defaultInitialValues,
        name: 'KVM',
      },
    });

    fireEvent.change(screen.getByLabelText('Name'), {
      target: { value: '' },
    });

    expect(screen.getByRole('button', { name: 'Submit' })).toBeDisabled();
  });

  it('submits edited values when form is valid', () => {
    const handleSubmit = jest.fn();

    renderModelForm({ handleSubmit });

    fireEvent.change(screen.getByLabelText('Name'), {
      target: { value: 'PowerEdge R760' },
    });
    fireEvent.change(screen.getByLabelText('Hardware model'), {
      target: { value: 'sun4u' },
    });
    fireEvent.change(screen.getByLabelText('Vendor class'), {
      target: { value: 'SUNW,Sun-Fire-V490' },
    });
    fireEvent.change(screen.getByLabelText('Info'), {
      target: { value: 'Requires custom BIOS setup' },
    });

    const submitButton = screen.getByRole('button', { name: 'Submit' });
    expect(submitButton).not.toBeDisabled();
    fireEvent.click(submitButton);

    expect(handleSubmit).toHaveBeenCalledWith({
      name: 'PowerEdge R760',
      hardware_model: 'sun4u',
      vendor_class: 'SUNW,Sun-Fire-V490',
      info: 'Requires custom BIOS setup',
    });
  });

  it('keeps submit disabled while submitting', () => {
    renderModelForm({
      initialValues: {
        ...defaultInitialValues,
        name: 'PowerEdge R760',
      },
      isSubmitting: true,
    });

    expect(screen.getByRole('button', { name: 'Submit' })).toBeDisabled();
  });

  it('navigates to models page on cancel', () => {
    const { history } = renderModelForm({
      initialValues: {
        ...defaultInitialValues,
        name: 'PowerEdge R760',
      },
    });

    fireEvent.click(screen.getByRole('button', { name: 'Cancel' }));

    expect(history.location.pathname).toBe(MODELS_PATH);
  });
});
