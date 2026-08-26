import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import { testComponentSnapshotsWithFixtures } from 'foremanReact/common/testHelpers';

import {
  integerSetting,
  rootPass,
  stringSetting,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import SettingValue from '../SettingValue';

const fixtures = {
  'render ordinary': {
    setting: stringSetting,
  },
  'render encrypted with fullName': {
    setting: rootPass,
  },
  'render without fullName': {
    setting: withoutFullName,
  },
};

describe('SettingCell', () =>
  testComponentSnapshotsWithFixtures(SettingValue, fixtures));

describe('SettingValue', () => {
  it('renders zero as a non-empty value', () => {
    render(<SettingValue setting={{ ...integerSetting, value: 0 }} />);

    expect(screen.getByText('0')).not.toHaveClass('empty-value');
  });

  it('marks a null value as empty', () => {
    render(<SettingValue setting={{ ...integerSetting, value: null }} />);

    expect(screen.getByText('Empty')).toHaveClass('empty-value');
  });
});
