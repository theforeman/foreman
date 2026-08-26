import React from 'react';
import { render, screen, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import {
  rootPass,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingName from '../SettingName';

const showTooltipFor = async visibleText => {
  userEvent.hover(screen.getByText(visibleText));

  await act(async () => {
    jest.runAllTimers();
  });

  return screen.getByRole('tooltip');
};

describe('SettingName', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('renders the full name and shows the setting name in the tooltip', async () => {
    render(<SettingName setting={rootPass} />);

    expect(screen.getByText('Root password')).toBeInTheDocument();

    const tooltip = await showTooltipFor('Root password');

    expect(tooltip).toHaveTextContent('root_pass');
  });

  it('falls back to the name when there is no full name', async () => {
    render(<SettingName setting={withoutFullName} />);

    expect(
      screen.getByText('always_show_configuration_status')
    ).toBeInTheDocument();

    const tooltip = await showTooltipFor('always_show_configuration_status');

    expect(tooltip).toHaveTextContent('always_show_configuration_status');
  });
});
