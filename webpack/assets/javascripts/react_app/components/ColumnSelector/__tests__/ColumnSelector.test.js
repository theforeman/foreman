import React from 'react';
import { act, render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { cloneDeep } from 'lodash';
import '@testing-library/jest-dom';
import ColumnSelector from '../ColumnSelector';
import { ColumnSelectorProps } from '../ColumnsSelector.fixtures';
import API from '../../../redux/API/API';
import { visit } from '../../../common/helpers';

const checkedColumnKeys = categories =>
  categories
    .flatMap(category => category.children)
    .filter(column => column.checkProps.checked)
    .map(column => column.key);

const { url: preferenceUrl, controller, categories } = ColumnSelectorProps.data;
const allColumnKeys = checkedColumnKeys(categories);

const renderColumnSelector = (dataOverrides = {}) => {
  const props = cloneDeep(ColumnSelectorProps);
  props.data = { ...props.data, ...dataOverrides };

  return render(<ColumnSelector {...props} />);
};

const openModal = () => {
  userEvent.click(screen.getByRole('button', { name: /manage columns/i }));
};

const getCheckbox = name =>
  screen.getByRole('checkbox', { name: new RegExp(`^${name}$`) });

describe('ColumnSelector', () => {
  beforeEach(() => {
    API.post.mockResolvedValue({});
    API.put.mockResolvedValue({});
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('renders the manage columns button', () => {
    renderColumnSelector();

    expect(
      screen.getByRole('button', { name: /manage columns/i })
    ).toBeInTheDocument();
  });

  it('opens the modal with categories, columns, and actions', () => {
    renderColumnSelector();

    expect(
      screen.queryByRole('dialog', { name: /manage columns/i })
    ).not.toBeInTheDocument();

    openModal();

    expect(
      screen.getByRole('dialog', { name: /manage columns/i })
    ).toBeInTheDocument();
    expect(
      screen.getByText('Select columns to display in the table.')
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Save' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeInTheDocument();

    expect(getCheckbox('General')).toBeChecked();
    expect(getCheckbox('Name')).toBeChecked();
    expect(getCheckbox('Name')).toBeDisabled();
    expect(getCheckbox('Operating system')).toBeChecked();
    expect(getCheckbox('Model')).toBeChecked();
    expect(getCheckbox('Owner')).toBeChecked();
    expect(getCheckbox('Host group')).toBeChecked();
    expect(getCheckbox('Last report')).toBeChecked();
    expect(getCheckbox('Comment')).toBeChecked();
  });

  it('closes the modal when Cancel is clicked', () => {
    renderColumnSelector();

    openModal();
    expect(
      screen.getByRole('dialog', { name: /manage columns/i })
    ).toBeInTheDocument();

    userEvent.click(screen.getByRole('button', { name: 'Cancel' }));

    expect(
      screen.queryByRole('dialog', { name: /manage columns/i })
    ).not.toBeInTheDocument();
  });

  it('closes the modal when the close button is clicked', () => {
    renderColumnSelector();

    openModal();
    expect(
      screen.getByRole('dialog', { name: /manage columns/i })
    ).toBeInTheDocument();

    userEvent.click(screen.getByRole('button', { name: 'Close' }));

    expect(
      screen.queryByRole('dialog', { name: /manage columns/i })
    ).not.toBeInTheDocument();
  });

  it('unchecking a column leaves the category partially selected', () => {
    renderColumnSelector();

    openModal();
    expect(getCheckbox('Comment')).toBeChecked();
    expect(getCheckbox('General')).toBeChecked();

    userEvent.click(getCheckbox('Comment'));

    expect(getCheckbox('Comment')).not.toBeChecked();
    expect(getCheckbox('General')).toHaveProperty('indeterminate', true);
    expect(getCheckbox('General')).not.toBeChecked();
  });

  it('toggles optional columns when the category checkbox is clicked', () => {
    renderColumnSelector();

    openModal();
    expect(getCheckbox('Operating system')).toBeChecked();
    expect(getCheckbox('Name')).toBeChecked();

    userEvent.click(getCheckbox('General'));

    expect(getCheckbox('Operating system')).not.toBeChecked();
    expect(getCheckbox('Model')).not.toBeChecked();
    expect(getCheckbox('Owner')).not.toBeChecked();
    expect(getCheckbox('Host group')).not.toBeChecked();
    expect(getCheckbox('Last report')).not.toBeChecked();
    expect(getCheckbox('Comment')).not.toBeChecked();
    expect(getCheckbox('Name')).toBeChecked();

    userEvent.click(getCheckbox('General'));

    expect(getCheckbox('Operating system')).toBeChecked();
    expect(getCheckbox('Comment')).toBeChecked();
    expect(getCheckbox('Name')).toBeChecked();
  });

  it('discards checkbox changes when Cancel is clicked', () => {
    renderColumnSelector();

    openModal();
    userEvent.click(getCheckbox('Comment'));
    expect(getCheckbox('Comment')).not.toBeChecked();

    userEvent.click(screen.getByRole('button', { name: 'Cancel' }));
    openModal();

    expect(getCheckbox('Comment')).toBeChecked();
  });

  it('saves an existing table preference with PUT', async () => {
    renderColumnSelector();

    openModal();
    userEvent.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => {
      expect(API.put).toHaveBeenCalledWith(`${preferenceUrl}/${controller}`, {
        columns: allColumnKeys,
      });
    });
    expect(API.post).not.toHaveBeenCalled();
    expect(visit).toHaveBeenCalled();
  });

  it('creates a table preference with POST when none exists', async () => {
    renderColumnSelector({ hasPreference: false });

    openModal();
    userEvent.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => {
      expect(API.post).toHaveBeenCalledWith(preferenceUrl, {
        name: controller,
        columns: allColumnKeys,
      });
    });
    expect(API.put).not.toHaveBeenCalled();
    expect(visit).toHaveBeenCalled();
  });

  it('omits unchecked columns from the saved preference', async () => {
    renderColumnSelector();

    openModal();
    expect(getCheckbox('Comment')).toBeChecked();

    userEvent.click(getCheckbox('Comment'));
    expect(getCheckbox('Comment')).not.toBeChecked();

    userEvent.click(screen.getByRole('button', { name: 'Save' }));

    await waitFor(() => {
      expect(API.put).toHaveBeenCalledWith(`${preferenceUrl}/${controller}`, {
        columns: allColumnKeys.filter(key => key !== 'comment'),
      });
    });
  });

  it('does not save when url or controller is missing', () => {
    render(<ColumnSelector />);

    expect(
      screen.getByRole('button', { name: /manage columns/i })
    ).toBeInTheDocument();

    openModal();
    userEvent.click(screen.getByRole('button', { name: 'Save' }));

    expect(API.put).not.toHaveBeenCalled();
    expect(API.post).not.toHaveBeenCalled();
    expect(visit).not.toHaveBeenCalled();
  });

  it('disables Save while the preference request is in progress', async () => {
    let resolvePut;
    API.put.mockImplementation(
      () =>
        new Promise(resolve => {
          resolvePut = resolve;
        })
    );

    renderColumnSelector();
    openModal();

    const saveButton = screen.getByRole('button', { name: 'Save' });
    expect(saveButton).toBeEnabled();

    userEvent.click(saveButton);

    expect(await screen.findByRole('progressbar')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /save/i })).toBeDisabled();

    await act(async () => {
      resolvePut({});
    });
  });
});
