import React from 'react';
import { render, fireEvent, act } from '@testing-library/react';
import {Provider} from "react-redux";
import thunk from 'redux-thunk';
import '@testing-library/jest-dom';
import NotificationIcon from '../components/NotificationIcon';
import {NotificationsContextWrapper} from '../NotificationsContext';
import configureMockStore from "redux-mock-store";
import {notificationsFixtures} from "./notifications.fixtures";

const mockStore = configureMockStore([thunk])
const store = mockStore({
  notifications: {
    notifications: notificationsFixtures,
    hasUnreadMessages: true
  }
})

describe('Notification Icon', () => {
  beforeEach(() => {
    render(
      <Provider store={store}>
        <NotificationsContextWrapper>
          <NotificationIcon />
        </NotificationsContextWrapper>
      </Provider>
    )
  })
  it('expand icon', async () => {
    const icon = document.querySelector('#notification-badge');
    expect(icon).toBeInTheDocument();

    await act( async () => {
      fireEvent.click(icon);
    })

    const iconExpanded = document.querySelector('#notification-badge span.pf-m-expanded');;
    expect(iconExpanded).toBeInTheDocument();

  });

});
