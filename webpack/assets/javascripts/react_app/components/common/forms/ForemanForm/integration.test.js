import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { Provider } from 'react-redux';
import { applyMiddleware, combineReducers, createStore } from 'redux';
import thunk from 'redux-thunk';

import { submitForm } from '../../../../redux/actions/common/forms';
import { initialValues, ConnectedFormComponent } from './ForemanForm.fixtures';
import { APIMiddleware } from '../../../../redux/API';
import APIHelper from '../../../../redux/API/API';
import apiReducer from '../../../../redux/API/APIReducer';

jest.mock('../../../../redux/API/API');

const nameErrors = ['is too long', 'should not contain numbers'];
const baseErrors = [
  'does not have enough vitamins',
  'does not have enough proteins',
];
const severity = 'warning';
const errorResponse = {
  response: {
    status: 422,
    data: {
      error: {
        errors: {
          name: nameErrors,
          base: baseErrors,
        },
        severity,
      },
    },
  },
};

const handleSubmit = (values, actions) =>
  submitForm({
    url: '/test/form',
    values,
    item: 'Test',
    message: 'Form was successfully created.',
    actions,
  });

const props = {
  submitForm: handleSubmit,
  onCancel: () => jest.fn,
  initValues: initialValues,
};

const renderForm = () => {
  const store = createStore(
    combineReducers({ apiReducer }),
    applyMiddleware(thunk, APIMiddleware)
  );

  return render(
    <Provider store={store}>
      <ConnectedFormComponent {...props} />
    </Provider>
  );
};

describe('ForemanForm integration test', () => {
  it('renders a warning alert with the base errors when submission fails', async () => {
    APIHelper.post.mockRejectedValue(errorResponse);

    renderForm();

    await userEvent.click(screen.getByRole('button', { name: 'Submit' }));

    // the base errors are surfaced in a warning alert
    expect(
      await screen.findByText('does not have enough vitamins')
    ).toBeInTheDocument();
    expect(
      screen.getByText('does not have enough proteins')
    ).toBeInTheDocument();
    expect(screen.getByText('Warning!')).toBeInTheDocument();
  });
});
