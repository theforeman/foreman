import React from 'react';
import { Provider } from 'react-redux';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import { fireEvent, screen, render, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import PersonalAccessTokenModal from './PersonalAccessTokenModal';
import * as APIActions from '../../../redux/API/APIActions';

jest.useFakeTimers();
jest.mock('../../../redux/API/APIActions');
const middlewares = [thunk];
const mockStore = configureMockStore(middlewares);
const store = mockStore({
  API: {},
  personalAccessTokens: {
    tokens: [],
  },
});

describe('Personal access token modal', () => {
  it('fills input fields and show errors', async () => {
    render(
      <Provider store={store}>
        <PersonalAccessTokenModal
          url="/url"
          controller="personal_access_tokens"
        />
      </Provider>
    );

    await act(async () => {
      fireEvent.click(screen.getByText('Add Personal Access Token'));
      jest.advanceTimersByTime(1000);
    });

    expect(
      screen.getByText('Create Personal Access Token')
    ).toBeInTheDocument();

    const atRadioButton = screen.getByText('At');
    const nameField = screen.getByLabelText('personal access token name input');
    const dateField = screen.getByLabelText('expiration date picker');
    const timeField = screen.getByLabelText('expiration time picker');
    const confirmButton = screen.getByText('Confirm');

    await act(async () => {
      fireEvent.change(nameField, {
        target: { value: 'testname' },
      });
      fireEvent.click(atRadioButton);
    });

    expect(screen.queryAllByDisplayValue('testname')).toHaveLength(1);
    expect(screen.queryAllByText('Fill out the name')).toHaveLength(0);
    expect(screen.queryAllByText('Fill out the date and time')).toHaveLength(1);

    await act(async () => {
      fireEvent.change(dateField, {
        target: { value: '2023-05-23' },
      });
    });

    expect(screen.queryAllByText('Cannot be in the past')).toHaveLength(1);

    await act(async () => {
      fireEvent.change(timeField, {
        target: { value: 'wrong-input' },
      });
    });

    expect(screen.queryAllByDisplayValue('wrong-input')).toHaveLength(1);
    expect(screen.queryAllByText('Cannot be in the past')).toHaveLength(0);
    expect(confirmButton).toHaveProperty('disabled', true);

    await act(async () => {
      fireEvent.change(dateField, {
        target: { value: '2500-01-01' },
      });
      fireEvent.change(timeField, {
        target: { value: '10:10:10' },
      });
    });

    expect(confirmButton).toHaveProperty('disabled', false);
  });

  it('fills input fields and successfully submits form', async () => {
    const spy = jest.spyOn(APIActions, 'post');
    APIActions.post.mockImplementation(() => {
      return { type: 'type', payload: {} };
    });

    render(
      <Provider store={store}>
        <PersonalAccessTokenModal
          url="/url"
          controller="personal_access_tokens"
        />
      </Provider>
    );

    await act(async () => {
      fireEvent.click(screen.getByText('Add Personal Access Token'));
      jest.advanceTimersByTime(1000);
    });

    const nameField = screen.getByLabelText('personal access token name input');
    const atRadioButton = screen.getByText('At');
    const dateField = screen.getByLabelText('expiration date picker');
    const timeField = screen.getByLabelText('expiration time picker');

    await act(async () => {
      fireEvent.change(nameField, {
        target: { value: 'token-name' },
      });
    });

    await act(async () => {
      fireEvent.click(atRadioButton);
      fireEvent.change(dateField, {
        target: { value: '2035-01-01' },
      });
    });

    await act(async () => {
      fireEvent.change(timeField, {
        target: { value: '01:00:00' },
      });
    });

    await act(async () => {
      fireEvent.click(screen.getByText('Confirm'));
    });

    expect(spy).toHaveBeenCalledWith(
      expect.objectContaining({
        key: 'PERSONAL_ACCESS_TOKEN_FORM_SUBMITTED',
        params: {
          controller: 'personal_access_tokens',
          expires_at: '2035-01-01 01:00:00',
          name: 'token-name',
        },
      })
    );
  });
});
