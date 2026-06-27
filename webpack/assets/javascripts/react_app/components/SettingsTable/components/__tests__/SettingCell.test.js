import React from 'react';
import { render, screen, within } from '@testing-library/react';
import '@testing-library/jest-dom';

import {
  rootPass,
  stringSetting,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingValue from '../SettingValue';

// Render the tooltip content inline instead of through the Popper, so the
// computed tooltipText can be asserted without hover/async teardown issues.
jest.mock('@patternfly/react-core', () => ({
  ...jest.requireActual('@patternfly/react-core'),
  Tooltip: ({ content, children }) => (
    <div>
      <div data-testid="tooltip-content">{content}</div>
      {children}
    </div>
  ),
}));

const tooltip = () => screen.getByTestId('tooltip-content');

describe('SettingCell', () => {
  afterEach(() => {
    jest.clearAllMocks();
  });

  it('render ordinary', () => {
    render(<SettingValue setting={stringSetting} />);

    const value = screen.getByText('root@example.com');
    expect(value).toBeInTheDocument();
    // value equals default, so it is not emphasized
    expect(value.closest('strong')).not.toBeInTheDocument();
    expect(
      within(tooltip()).getByText('Default: root@example.com')
    ).toBeInTheDocument();
  });

  it('render encrypted with fullName', () => {
    render(<SettingValue setting={rootPass} />);

    // encrypted value is masked, and emphasized because it differs from default
    const value = screen.getByText('*****');
    expect(value).toBeInTheDocument();
    expect(value.closest('strong')).toBeInTheDocument();
    // encrypted default is masked with bullet operators, one per character
    expect(
      within(tooltip()).getByText(`Default: ${'∙'.repeat(6)}`)
    ).toBeInTheDocument();
  });

  it('render without fullName', () => {
    render(<SettingValue setting={withoutFullName} />);

    // boolean false renders as "No"
    const value = screen.getByText('No');
    expect(value).toBeInTheDocument();
    expect(value.closest('strong')).not.toBeInTheDocument();
    expect(within(tooltip()).getByText('Default: No')).toBeInTheDocument();
  });
});
