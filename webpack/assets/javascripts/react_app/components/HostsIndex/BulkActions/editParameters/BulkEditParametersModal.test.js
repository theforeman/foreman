import React from 'react';
import { act, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { IntlProvider } from 'react-intl';
import {
  flushPatternflyTimers,
  rtlHelpers,
} from '../../../../common/rtlTestHelpers';
import { STATUS } from '../../../../constants';
import BulkEditParametersModal from './BulkEditParametersModal';
import { bulkUpdateParameters } from './actions';
import { usePermissions } from '../../../../common/hooks/Permissions/permissionHooks';

jest.mock('../../../../common/I18n');

jest.mock('../../../../common/hooks/Permissions/permissionHooks', () => ({
  usePermissions: jest.fn(() => true),
}));

jest.mock('./actions', () => ({
  bulkUpdateParameters: jest.fn(() => ({
    type: 'BULK_UPDATE_PARAMETERS_MOCK',
  })),
  fetchCommonParameters: jest.fn(() => ({
    type: 'FETCH_COMMON_PARAMETERS_MOCK',
  })),
}));

const { renderWithStore } = rtlHelpers;

const chooseParameter = async name => {
  await act(async () => {
    userEvent.click(screen.getByPlaceholderText('Select a global parameter'));
  });
  await flushPatternflyTimers();
  await act(async () => {
    userEvent.click(screen.getByRole('option', { name }));
  });
  await flushPatternflyTimers();
};

const resolvedApiState = {
  API: {
    COMMON_PARAMETERS: {
      status: STATUS.RESOLVED,
      response: {
        results: [
          { id: 1, name: 'p1', parameter_type: 'string' },
          { id: 2, name: 'p2', parameter_type: 'string' },
        ],
      },
    },
  },
};

const defaultProps = {
  selectedCount: 5,
  fetchBulkParams: jest.fn(() => 'id ^ (1,2,3,4,5)'),
  organizationId: 1,
  locationId: 2,
  isOpen: true,
  closeModal: jest.fn(),
};

const renderModal = (props = {}, initialState = resolvedApiState) =>
  renderWithStore(
    <IntlProvider locale="en">
      <BulkEditParametersModal {...defaultProps} {...props} />
    </IntlProvider>,
    initialState
  );

describe('BulkEditParametersModal', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    usePermissions.mockReturnValue(true);
  });

  it('renders modal with title and fields', () => {
    renderModal();
    expect(screen.getByText('Set parameters')).toBeInTheDocument();
    expect(screen.getByLabelText('Parameter')).toBeInTheDocument();
    expect(screen.getByLabelText('Value')).toBeInTheDocument();
  });

  it('displays host count in description', () => {
    renderModal();
    expect(
      screen.getByText(/Set a host parameter override on/)
    ).toHaveTextContent('Set a host parameter override on 5 selected hosts.');
  });

  it('uses singular form for a single host', () => {
    renderModal({ selectedCount: 1 });
    expect(
      screen.getByText(/Set a host parameter override on/)
    ).toHaveTextContent('Set a host parameter override on 1 selected host.');
  });

  it('has Confirm disabled until a parameter and value are set', async () => {
    renderModal();
    const confirmBtn = screen.getByRole('button', { name: 'Confirm' });
    expect(confirmBtn).toBeDisabled();

    await chooseParameter('p1');
    expect(
      screen.getByPlaceholderText('Select a global parameter')
    ).toHaveValue('p1');
    expect(confirmBtn).toBeDisabled();

    userEvent.type(screen.getByLabelText('Value'), 'hello');
    expect(confirmBtn).not.toBeDisabled();
  });

  it('calls closeModal on Cancel', async () => {
    const closeModal = jest.fn();
    renderModal({ closeModal });

    userEvent.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(closeModal).toHaveBeenCalled();
  });

  it('dispatches the bulk update action on Confirm', async () => {
    renderModal();

    await chooseParameter('p1');
    userEvent.type(screen.getByLabelText('Value'), 'hello');
    userEvent.click(screen.getByRole('button', { name: 'Confirm' }));

    expect(bulkUpdateParameters).toHaveBeenCalledWith(
      expect.objectContaining({
        name: 'p1',
        value: 'hello',
        included: { search: 'id ^ (1,2,3,4,5)' },
      }),
      expect.any(Function),
      expect.any(Function)
    );
  });

  it('does not render when isOpen is false', () => {
    renderModal({ isOpen: false });
    expect(screen.queryByText('Set parameters')).not.toBeInTheDocument();
  });

  it('explains that missing overrides will be created when the user can create params', () => {
    renderModal();
    expect(
      screen.getByText(/Hosts that already have this parameter will be updated/)
    ).toBeInTheDocument();
    expect(
      screen.queryByText(
        /You can only update parameters that already exist on the selected hosts/
      )
    ).not.toBeInTheDocument();
  });

  it('shows an edit-only alert when the user cannot create params', () => {
    usePermissions.mockReturnValue(false);
    renderModal();

    expect(
      screen.getByText(
        /You can only update parameters that already exist on the selected hosts/
      )
    ).toBeInTheDocument();
    expect(
      screen.queryByText(
        /Hosts that already have this parameter will be updated/
      )
    ).not.toBeInTheDocument();
  });
});
