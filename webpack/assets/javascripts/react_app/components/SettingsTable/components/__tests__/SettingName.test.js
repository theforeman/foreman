import React from 'react';
import { render, screen, within } from '@testing-library/react';
import '@testing-library/jest-dom';

import {
  rootPass,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingName from '../SettingName';

// Render the tooltip content inline instead of through the Popper, so the
// tooltipText can be asserted without hover/async teardown issues.
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

describe('SettingName', () => {
  it('render with fullName', () => {
    render(<SettingName setting={rootPass} />);

    // fullName is shown as the name, the technical name is the tooltip
    expect(screen.getByText('Root password')).toBeInTheDocument();
    expect(within(tooltip()).getByText('root_pass')).toBeInTheDocument();
  });

  it('render without fullName', () => {
    render(<SettingName setting={withoutFullName} />);

    // with no fullName, the technical name is used for both name and tooltip
    expect(
      within(tooltip()).getByText('always_show_configuration_status')
    ).toBeInTheDocument();
    expect(
      screen.getAllByText('always_show_configuration_status')
    ).toHaveLength(2);
  });
});
