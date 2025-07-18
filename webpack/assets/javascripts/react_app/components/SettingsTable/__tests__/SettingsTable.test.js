import { testComponentSnapshotsWithFixtures } from '@theforeman/test';
import React from "react";
import {render, screen, within} from '@testing-library/react'
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom'
import {Provider} from "react-redux";

import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';

import { groupedSettings } from '../../SettingRecords/__tests__/SettingRecords.fixtures';
import SettingsTable from '../SettingsTable';
import {APIActions} from "../../../redux/API";

const fixtures = {
  'should render': {
    settings: groupedSettings['General'],
    onEditClick: () => {},
  },
};
const mockStore = configureMockStore([thunk]);
const store = mockStore({

})

jest.spyOn(APIActions, 'put').mockReturnValue({ type: 'DUMMY' });

describe('SettingsTableSnapshot', () =>
    testComponentSnapshotsWithFixtures(SettingsTable, fixtures)
)

async function extracted(text = '') {
  const editButton = document.querySelector('button#http_proxy_except_list');

  expect(editButton).toBeInTheDocument();
  await userEvent.click(editButton);

  const input = document.querySelector(
    'textarea#setting-textarea-http_proxy_except_list'
  );
  expect(input).toBeInTheDocument();

  await userEvent.clear(input);
  if (text !== '')  await userEvent.type(input, text);

  const submitBtn = document.querySelector(
    'button[data-ouia-component-id="submit-edit-btn"]'
  );
  expect(submitBtn).toBeInTheDocument();
  await userEvent.click(submitBtn);
}

describe('SettingsTable', () => {
  beforeEach(() => {
    render(
        <Provider store={store}>
          <SettingsTable settings={groupedSettings['General']} />
        </Provider>
    );
  });

  it('renders the header row with the correct OUIA id', () => {
    const headerRow = document.querySelector(
        'tr[data-ouia-component-id="setting-table-heading-row"]'
    );
    expect(headerRow).toBeInTheDocument();
  });

  it('renders Name, Value and Description column headers', () => {
    const headers = screen.getAllByRole('columnheader')

    expect(headers).toHaveLength(3);

    expect(headers[0]).toHaveTextContent('Name');
    expect(headers[1]).toHaveTextContent('Value');
    expect(headers[2]).toHaveTextContent('Description');
  });

  test('renders one row per setting + header', () => {
    const rows = screen.getAllByRole('row')

    expect(rows).toHaveLength(5)
  })

  it('string input test', async () => {
    const allRows = screen.getAllByRole('row');
    expect(allRows.length).toBeGreaterThan(1); // sanity check

    const firstBodyRow = allRows[1];

    const {getByRole} = within(firstBodyRow);
    const editButton = getByRole('button');

    expect(editButton).toBeInTheDocument();
    await userEvent.click(editButton);

    const input = document.querySelector(
        'input[data-ouia-component-id="setting-input-administrator"]'
    );
    expect(input).toBeInTheDocument();

    await userEvent.clear(input);
    await userEvent.type(input, 'Test');

    const submitBtn = document.querySelector(
        'button[data-ouia-component-id="submit-edit-btn"]'
    );
    expect(submitBtn).toBeInTheDocument();
    await userEvent.click(submitBtn)

    expect(APIActions.put).toHaveBeenCalledTimes(1);
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: 'Test' }),
        })
    );
  })


  it('select value test', async () => {
    const editButton = document.querySelector(
        'button#display_fqdn_for_hosts'
    );

    expect(editButton).toBeInTheDocument();
    await userEvent.click(editButton);

    const input = document.querySelector(
        'select[data-ouia-component-id="setting-select-display_fqdn_for_hosts"]'
    );
    expect(input).toBeInTheDocument();

    await userEvent.selectOptions(input, 'No')

    const submitBtn = document.querySelector(
        'button[data-ouia-component-id="submit-edit-btn"]'
    );
    expect(submitBtn).toBeInTheDocument();
    await userEvent.click(submitBtn)

    expect(APIActions.put).toHaveBeenCalledTimes(2);
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: 'false' }),
        })
    );
  })


  it('array edit one value', async () => {
    await extracted('Test');
    expect(APIActions.put).toHaveBeenCalledTimes(3);
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: ['Test'] }),
        })
    );
  })

  it('array edit two values', async () => {
    await extracted('Test, Test2');
    expect(APIActions.put).toHaveBeenCalledTimes(4);
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: ['Test', 'Test2'] }),
        })
    );
  })

  it('array edit empty value', async () => {
    await extracted();
    expect(APIActions.put).toHaveBeenCalledTimes(5);
    expect(APIActions.put).toHaveBeenCalledWith(
        expect.objectContaining({
          params: expect.objectContaining({ value: [] }),
        })
    );
  })

});
