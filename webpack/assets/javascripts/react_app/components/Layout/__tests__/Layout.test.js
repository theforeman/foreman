import React from 'react';
import { Provider } from 'react-redux';
import configureMockStore from 'redux-mock-store';
import { BrowserRouter as Router } from 'react-router-dom';
import { fireEvent, screen, render, act } from '@testing-library/react';
import "@testing-library/jest-dom/extend-expect"; // for toBeVisable
import Layout from '../index';
import { layoutData, fullLayoutStore } from '../Layout.fixtures';
import { initMockStore } from '../../../common/testHelpers';
import { reducers } from '../index';

const mockStore = configureMockStore(reducers);
const store = mockStore({ ...initMockStore, ...fullLayoutStore });

jest.useFakeTimers();
describe('Layout', () => {
  it('Layout', async () => {
    render(
      <Provider store={store}>
        <Router>
          <Layout data={layoutData} />
        </Router>
      </Provider>
    );
    expect(screen.getByText('Monitor')).toBeVisible();
    expect(screen.getByText('Dashboard')).toBeVisible();
    expect(screen.getByText('All Hosts')).not.toBeVisible();
    await act(async () => {
      await fireEvent.click(screen.getByText('Hosts'));
    });
    expect(screen.getByText('All Hosts')).toBeVisible();
    expect(screen.getByText('Dashboard')).toBeVisible();
  });
});
