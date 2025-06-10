import React from "react";
import {render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom'
import {Provider} from "react-redux";
import SearchModal from "../SearchModal";
import {APIActions} from "../../../redux/API";
import store from '../../../redux';

jest.spyOn(APIActions, 'post').mockReturnValue({ type: 'DUMMY'})

const setClosedMock = jest.fn();

describe('BookmarkForm tests', () => {
    beforeEach(() => {
        render(
          <Provider store={store}>
              <SearchModal
                setModalClosed={setClosedMock}
                controller="Bookmarks"
                url="/"
                searchQuery="test"
                isOpened={true}
                bookmarks={[{
                    "name": "exists",
                    "controller": "dashboard",
                    "query": "service_level",
                    "public": true,
                    "id": 20,
                    "owner_id": 4,
                    "owner_type": "User"
                }]}
              />
          </Provider>
        )
    })

    it('Opened Bookmark modal', () => {
        expect(screen.getByText('Create Bookmark')).toBeInTheDocument();
        expect(screen.getByText('Name')).toBeInTheDocument();
        expect(screen.getByText('Query')).toBeInTheDocument();
        expect(screen.getByText('Public')).toBeInTheDocument();
    })

    it('Test wrong name inputs', async () => {
        // check name
        const input = document.querySelector('input#name-input');
        const submitBtn = document.querySelector('button[data-ouia-component-id="submit-btn"]')

        expect(input).toBeInTheDocument();
        expect(submitBtn).toBeDisabled()

        // existing input
        await userEvent.clear(input);
        await userEvent.type(input, 'exists')
        expect(input).toHaveValue('exists');
        expect(screen.getByText('Name already exists')).toBeInTheDocument();
        expect(submitBtn).toBeDisabled()
    })

    it('Submit only space as name', async () => {
        const input = document.querySelector('input#name-input');
        const submitBtn = document.querySelector('button[data-ouia-component-id="submit-btn"]')

        expect(input).toBeInTheDocument();
        expect(submitBtn).toBeDisabled()

        // existing input
        await userEvent.clear(input);
        await userEvent.type(input, 'new');
        expect(input).toHaveValue('new');

        expect(submitBtn).not.toBeDisabled()

    })

    it('Submit correct bookmark', async () => {
        const submitBtn = document.querySelector('button[data-ouia-component-id="submit-btn"]')
        expect(submitBtn).toBeDisabled()

        const nameInput = document.querySelector('input#name-input');
        expect(nameInput).toBeInTheDocument();

        await userEvent.clear(nameInput);
        await userEvent.type(nameInput, 'New');
        expect(nameInput).toHaveValue('New');


        const queryInput = document.querySelector('input#query-input');
        expect(queryInput).toBeInTheDocument();

        await userEvent.clear(queryInput);
        await userEvent.type(queryInput, 'New');
        expect(queryInput).toHaveValue('New');


        await userEvent.click(submitBtn);

        expect(APIActions.post).toHaveBeenCalledTimes(1);
    })

    it('Check empty query', async () => {
        const submitBtn = document.querySelector('button[data-ouia-component-id="submit-btn"]')
        expect(submitBtn).toBeDisabled()

        const nameInput = document.querySelector('input#name-input');
        expect(nameInput).toBeInTheDocument();

        await userEvent.clear(nameInput);
        await userEvent.type(nameInput, 'New');
        expect(nameInput).toHaveValue('New');

        const queryInput = document.querySelector('input#query-input');
        expect(queryInput).toBeInTheDocument();

        await userEvent.clear(queryInput);
        expect(queryInput).toHaveValue('');

        expect(submitBtn).toBeDisabled()
    })

    it('Close modal', async () => {
        const cancelBtn = document.querySelector('button[data-ouia-component-id="cancel-btn"]')
        expect(cancelBtn).toBeInTheDocument();

        await userEvent.click(cancelBtn);

        expect(setClosedMock).toHaveBeenCalledTimes(1);
    })
})