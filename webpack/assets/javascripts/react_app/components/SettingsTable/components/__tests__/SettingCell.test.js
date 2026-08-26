import { testComponentSnapshotsWithFixtures } from 'foremanReact/common/testHelpers';

import {
  rootPass,
  stringSetting,
  withoutFullName,
} from '../../../SettingRecords/__tests__/SettingRecords.fixtures';

import React from 'react';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import SettingValue from '../SettingValue';
import SettingValueCell from '../SettingValueCell';
import { APIActions } from '../../../../redux/API';
import { rtlHelpers } from '../../../../common/rtlTestHelpers';

const { renderWithStore } = rtlHelpers;

const fixtures = {
  'render ordinary': { setting: stringSetting },
  'render encrypted with fullName': { setting: rootPass },
  'render without fullName': { setting: withoutFullName },
};

describe('SettingCell', () =>
  testComponentSnapshotsWithFixtures(SettingValue, fixtures));

describe('SettingValueCell encrypted flag updates after save', () => {
  it('updates displayed value and encrypted flag from server response', async () => {
    const setting = { id: 'http_proxy', name: 'http_proxy', value: '', encrypted: false };

    const apiResponse = {
      id: 'http_proxy',
      name: 'http_proxy',
      value: 'http://user:pass@h:1',
      encrypted: true
    };

    // Mock APIActions.put to call the success handler with our response
    const putSpy = jest.spyOn(APIActions, 'put').mockImplementation((request) => {
      // Call the success handler immediately with the mocked response
      if (request.handleSuccess) {
        request.handleSuccess({ data: apiResponse });
      }
      return { type: 'API_PUT_MOCK' };
    });

    renderWithStore(<SettingValueCell setting={setting} index={0} />);

    // open edit mode
    const editButton = document.querySelector(`button#${setting.name}`);
    await userEvent.click(editButton);

    // verify edit mode is active
    expect(screen.getByRole('textbox')).toBeInTheDocument();

    // enter new value and submit
    const input = screen.getByRole('textbox');
    await userEvent.clear(input);
    await userEvent.type(input, 'http://user:pass@h:1');

    const submitButton = document.querySelector('[data-ouia-component-id="submit-edit-btn"]');
    await userEvent.click(submitButton);

    // rendered value should be masked after update
    await waitFor(() => {
      expect(screen.getByText('*****')).toBeInTheDocument();
    });

    putSpy.mockRestore();
  });

  it('updates displayed value when encryption flag is removed', async () => {
    const setting = { id: 'http_proxy', name: 'http_proxy', value: '*****', encrypted: true };

    const apiResponse = {
      id: 'http_proxy',
      name: 'http_proxy',
      value: 'http://host:8080',
      encrypted: false
    };

    // Mock APIActions.put to call the success handler with our response
    const putSpy = jest.spyOn(APIActions, 'put').mockImplementation((request) => {
      if (request.handleSuccess) {
        request.handleSuccess({ data: apiResponse });
      }
      return { type: 'API_PUT_MOCK' };
    });

    renderWithStore(<SettingValueCell setting={setting} index={0} />);

    const editButton = document.querySelector(`button#${setting.name}`);
    await userEvent.click(editButton);

    const input = screen.getByRole('textbox');
    await userEvent.clear(input);
    await userEvent.type(input, 'http://host:8080');

    const submitButton = document.querySelector('[data-ouia-component-id="submit-edit-btn"]');
    await userEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('http://host:8080')).toBeInTheDocument();
    });

    putSpy.mockRestore();
  });
});
