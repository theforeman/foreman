import React, {useContext, useEffect} from 'react';
import { fireEvent, screen, render, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import Notifications from '../index';
import {NotificationsContext, NotificationsContextWrapper} from '../NotificationsContext';
import { Provider } from 'react-redux';
import configureMockStore from "redux-mock-store";
import thunk from 'redux-thunk';
import {notificationsFixtures} from "./notifications.fixtures";
import {API} from "../../../redux/API";
import { documentLocale } from '../../../common/I18n';

jest.mock('../../../redux/API/API');
jest.mock('../../../common/I18n');



API.put.mockResolvedValue({});
API.delete.mockResolvedValue({});
documentLocale.mockReturnValue('en');



const mockStore = configureMockStore([thunk])
const store = mockStore({
    notifications: {
        notifications: notificationsFixtures,
        hasUnreadMessages: true
    }
})

const ForceExpanded = () => {
    const { setIsExpanded } = useContext(NotificationsContext);
    useEffect(() => {
        setIsExpanded(true);
    }, [setIsExpanded]);
    return null;
};

describe('Notification drawer test', () => {
    beforeEach(() => {
        render(
          <Provider store={store}>
              <NotificationsContextWrapper>
                  <ForceExpanded />
                  <Notifications />
              </NotificationsContextWrapper>
          </Provider>
        )
    })

    it('notification groups and items render', () => {
        expect(screen.getByText('Reports')).toBeInTheDocument();
        expect(screen.getByText('Jobs')).toBeInTheDocument();

        expect(screen.getByText('1 unread')).toBeInTheDocument();
    });

    it('shows action buttons in header', async () => {
        // dots main dropdown
        const mainDropdown = document.querySelector('button[data-ouia-component-id="notification-header-dropdown-btn"]')
        expect(mainDropdown).toBeInTheDocument();
        await act(async  () => {
            fireEvent.click(mainDropdown);
        })

        // dropdown items
        expect(screen.getByText('Mark all read')).toBeInTheDocument();
        expect(screen.getByText('Clear all')).toBeInTheDocument();
    });

    it('full process', async () => {
        const jobsGroupToggle = document.querySelector('#Reports button');
        expect(jobsGroupToggle).toBeInTheDocument();
        await act(async  () => {
            fireEvent.click(jobsGroupToggle);
        })

        // group item
        const jobItem = screen.getByText('A job \'Run scan for all OpenSCAP policies on host\' has failed');
        expect(jobItem).toBeInTheDocument();
        expect(document.querySelector('button[data-ouia-component-id="clear-group-btn-Jobs"]')).toBeInTheDocument();
        let markAsRead = document.querySelector('button[data-ouia-component-id="read-group-btn-Jobs"]');
        expect(markAsRead).toBeInTheDocument()

        // item dots menu
        const jobMenu = document.querySelector('button[data-ouia-component-id="menuToggle-43"]')
        expect(jobMenu).toBeInTheDocument();
        await act(async  () => {
            fireEvent.click(jobMenu);
        });
        expect(API.put).toHaveBeenCalledWith('/notification_recipients/43', { seen: true });


        // opened menu
        expect(screen.getByText('Job Details')).toBeInTheDocument()

        const jobHideBtn = screen.getByText('Hide this notification').closest('button')
        expect(jobHideBtn).toBeInTheDocument();
        await act(async  () => {
            fireEvent.click(jobHideBtn)
        })
        expect(API.delete).toHaveBeenCalledWith('/notification_recipients/43');

        // reports group use clear group
        const reportsGroupToggle = document.querySelector('button[data-ouia-component-id="menuToggle-42"]')
        expect(reportsGroupToggle).toBeInTheDocument();

        await act(async  () => {
            fireEvent.click(reportsGroupToggle)
        })

        expect(screen.getByText('Report "Job - Invocation Report" is ready to download')).toBeInTheDocument()



        const clearGroupBtn = document.querySelector('button[data-ouia-component-id="clear-group-btn-Reports"]')
        expect(clearGroupBtn).toBeInTheDocument()

        //clear group
        await act(async  () => {
            fireEvent.click(clearGroupBtn)
        })
        expect(API.delete).toHaveBeenCalledWith('/notification_recipients/group/Reports');

    });
});