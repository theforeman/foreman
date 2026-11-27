import React from 'react';
import { act, fireEvent, screen, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Table, Tbody } from '@patternfly/react-table';
import { API } from '../../../../redux/API';
import {
  flushPatternflyTimers,
  rtlHelpers,
} from '../../../../common/rtlTestHelpers';
import { EditParametersTableRow } from './EditTableRow';

jest.mock('../../../../redux/API/API');

const { renderWithStore } = rtlHelpers;

const param = {
  id: 7,
  name: 'enable_feature',
  parameter_type: 'string',
  value: 'yes',
  'hidden_value?': false,
  associated_type: 'host',
};

const renderRow = (rowParam = param) =>
  renderWithStore(
    <Table aria-label="parameters">
      <Tbody>
        <EditParametersTableRow
          param={rowParam}
          rowIndex={0}
          setEditingRow={jest.fn()}
          hostId={1}
          editHostsPermission
        />
      </Tbody>
    </Table>
  );

const chooseOption = async (toggleName, optionName) => {
  await act(async () => {
    fireEvent.click(screen.getByRole('button', { name: toggleName }));
  });
  await flushPatternflyTimers();
  await act(async () => {
    fireEvent.click(screen.getByRole('option', { name: optionName }));
  });
  await flushPatternflyTimers();
};

describe('EditParametersTableRow', () => {
  beforeEach(() => {
    API.put.mockResolvedValue({ data: {} });
  });

  it('shows the current type in the type select', () => {
    renderRow();
    expect(
      screen.getByRole('button', { name: 'Select enable_feature type' })
    ).toHaveTextContent('string');
  });

  it('keeps the OUIA id on the value textarea for QE automation', () => {
    renderRow();
    expect(screen.getByLabelText('enable_feature value text')).toHaveAttribute(
      'data-ouia-component-id',
      'edit-parameters-table-row-value-0'
    );
  });

  it('switches the value input to a boolean select when type becomes boolean', async () => {
    renderRow();
    expect(
      screen.getByLabelText('enable_feature value text')
    ).toBeInTheDocument();

    await chooseOption('Select enable_feature type', 'boolean');

    expect(
      screen.getByRole('button', { name: 'Select enable_feature type' })
    ).toHaveTextContent('boolean');
    expect(
      screen.getByRole('button', { name: 'Select enable_feature value' })
    ).toBeInTheDocument();
    expect(
      screen.queryByLabelText('enable_feature value text')
    ).not.toBeInTheDocument();
  });

  it('submits the chosen boolean value', async () => {
    renderRow({ ...param, parameter_type: 'boolean', value: false });
    const valueToggle = screen.getByRole('button', {
      name: 'Select enable_feature value',
    });
    expect(valueToggle).toHaveTextContent('false');

    await chooseOption('Select enable_feature value', 'true');
    expect(valueToggle).toHaveTextContent('true');

    await act(async () => {
      fireEvent.click(
        screen.getByRole('button', { name: 'submit enable_feature edit' })
      );
    });
    await flushPatternflyTimers();
    await waitFor(() => expect(API.put).toHaveBeenCalled());
    expect(API.put.mock.calls[0][0]).toBe('/api/hosts/1/parameters/7');
    expect(API.put.mock.calls[0][1]).toEqual(
      expect.objectContaining({ value: 'true', parameter_type: 'boolean' })
    );
  });
});
