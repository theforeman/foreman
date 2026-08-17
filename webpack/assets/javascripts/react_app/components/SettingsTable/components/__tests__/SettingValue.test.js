import React from 'react';
import { render, screen, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import {
  integerSetting,
  rootPass,
  stringSetting,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingValue from '../SettingValue';

const showTooltipFor = async visibleText => {
  userEvent.hover(screen.getByText(visibleText));

  await act(async () => {
    jest.runAllTimers();
  });

  return screen.getByRole('tooltip');
};

describe('SettingValue', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('renders an ordinary string setting and shows its default in the tooltip', async () => {
    render(<SettingValue setting={stringSetting} />);

    expect(screen.getByText('root@example.com')).toBeInTheDocument();

    const tooltip = await showTooltipFor('root@example.com');

    expect(tooltip).toHaveTextContent('Default: root@example.com');
  });

  it('renders an encrypted setting with a masked default in the tooltip', async () => {
    render(<SettingValue setting={rootPass} />);

    expect(screen.getByText('*****')).toBeInTheDocument();

    const tooltip = await showTooltipFor('*****');

    expect(tooltip).toHaveTextContent('Default: ∙∙∙∙∙∙');
  });

  it('renders a boolean setting as No', async () => {
    render(<SettingValue setting={withoutFullName} />);

    expect(screen.getByText('No')).toBeInTheDocument();

    const tooltip = await showTooltipFor('No');

    expect(tooltip).toHaveTextContent('Default: No');
  });

  it('shows a read-only tooltip when the setting is defined in a config file', async () => {
    const readonlySetting = { ...stringSetting, readonly: true };

    render(<SettingValue setting={readonlySetting} />);

    expect(screen.getByText('root@example.com')).toBeInTheDocument();

    const tooltip = await showTooltipFor('root@example.com');

    expect(tooltip).toHaveTextContent(
      'This setting is defined in the configuration file settings.yaml and is read-only.'
    );
  });

  it('renders Empty when the setting has no value', () => {
    render(
      <SettingValue
        setting={{ ...stringSetting, value: null, default: 'root@example.com' }}
      />
    );

    expect(screen.getByText('Empty')).toBeInTheDocument();
  });

  it('renders zero as a non-empty value', () => {
    render(<SettingValue setting={{ ...integerSetting, value: 0 }} />);

    expect(screen.getByText('0')).not.toHaveClass('empty-value');
  });

  it('marks a null value as empty', () => {
    render(<SettingValue setting={{ ...integerSetting, value: null }} />);

    expect(screen.getByText('Empty')).toHaveClass('empty-value');
  });
});
