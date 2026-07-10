import React from 'react';
import { render, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { BYTES_PER_MB } from '../constants';
import MemoryAllocationInput from '../';

describe('MemoryAllocationInput', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('calls setWarning when value exceeds recommendedMaxValue', async () => {
    const setWarning = jest.fn();
    render(
      <MemoryAllocationInput
        value={11264 * BYTES_PER_MB}
        recommendedMaxValue={10240}
        setWarning={setWarning}
      />
    );

    const input = screen.getByRole('spinbutton');
    expect(input).toHaveValue(11264);

    await waitFor(() => {
      expect(setWarning).toHaveBeenCalledTimes(1);
    });
  });

  it('calls setError when value exceeds maxValue', async () => {
    const setError = jest.fn();
    render(
      <MemoryAllocationInput
        value={21504 * BYTES_PER_MB}
        maxValue={20480 * BYTES_PER_MB}
        setError={setError}
      />
    );

    const input = screen.getByRole('spinbutton');
    expect(input).toHaveValue(21504);

    await waitFor(() => {
      expect(setError).toHaveBeenCalledTimes(1);
    });
  });
});
