import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';

import RadioButton from './RadioButton';

const requiredProps = { input: { some: 'input', onChange: () => {} } };

describe('RadioButton', () => {
  it('renders an unchecked, enabled radio by default', () => {
    render(<RadioButton {...requiredProps} />);

    const radio = screen.getByRole('radio');
    expect(radio).toBeInTheDocument();
    expect(radio).not.toBeChecked();
    expect(radio).toBeEnabled();
    expect(radio).toHaveAttribute('some', 'input');
  });

  it('renders the item label and value', () => {
    render(
      <RadioButton
        {...requiredProps}
        item={{ label: 'some-label', checked: true, value: 'some-value' }}
      />
    );

    expect(screen.getByText('some-label')).toBeInTheDocument();
    expect(screen.getByRole('radio')).toHaveAttribute('value', 'some-value');
  });

  it('renders a disabled radio', () => {
    render(<RadioButton {...requiredProps} disabled />);

    expect(screen.getByRole('radio')).toBeDisabled();
  });
});
