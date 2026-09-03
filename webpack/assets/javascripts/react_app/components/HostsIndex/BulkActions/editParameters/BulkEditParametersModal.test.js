import React from 'react';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { IntlProvider } from 'react-intl';
import { rtlHelpers } from '../../../../common/rtlTestHelpers';
import { STATUS } from '../../../../constants';
import BulkEditParametersModal from './BulkEditParametersModal';
import { bulkUpdateParameters } from './actions';

jest.mock('../../../../common/I18n');

jest.mock('./actions', () => ({
  bulkUpdateParameters: jest.fn(() => ({
    type: 'BULK_UPDATE_PARAMETERS_MOCK',
  })),
  fetchCommonParameters: jest.fn(() => ({
    type: 'FETCH_COMMON_PARAMETERS_MOCK',
  })),
}));

jest.mock('@patternfly/react-templates', () => ({
  TypeaheadSelect: ({
    selectOptions,
    onSelect,
    selected,
    placeholder,
    toggleProps,
  }) => (
    <select
      aria-label={toggleProps?.['aria-label'] || 'Parameter'}
      value={selected || ''}
      disabled={toggleProps?.isDisabled}
      onChange={event => onSelect(event, event.target.value)}
    >
      <option value="">{placeholder}</option>
      {selectOptions.map(opt => (
        <option key={opt.value} value={opt.value}>
          {opt.content}
        </option>
      ))}
    </select>
  ),
}));

const { renderWithStore } = rtlHelpers;

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
    ).toHaveTextContent(
      'Set a host parameter override on 5 selected hosts.'
    );
  });

  it('uses singular form for a single host', () => {
    renderModal({ selectedCount: 1 });
    expect(
      screen.getByText(/Set a host parameter override on/)
    ).toHaveTextContent(
      'Set a host parameter override on 1 selected host.'
    );
  });

  it('has Confirm disabled until a parameter and value are set', async () => {
    renderModal();
    const confirmBtn = screen.getByRole('button', { name: 'Confirm' });
    expect(confirmBtn).toBeDisabled();

    await userEvent.selectOptions(screen.getByLabelText('Parameter'), 'p1');
    expect(confirmBtn).toBeDisabled();

    await userEvent.type(screen.getByLabelText('Value'), 'hello');
    expect(confirmBtn).not.toBeDisabled();
  });

  it('calls closeModal on Cancel', async () => {
    const closeModal = jest.fn();
    renderModal({ closeModal });

    await userEvent.click(screen.getByRole('button', { name: 'Cancel' }));
    expect(closeModal).toHaveBeenCalled();
  });

  it('dispatches the bulk update action on Confirm', async () => {
    renderModal();

    await userEvent.selectOptions(screen.getByLabelText('Parameter'), 'p1');
    await userEvent.type(screen.getByLabelText('Value'), 'hello');
    await userEvent.click(screen.getByRole('button', { name: 'Confirm' }));

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
});
