/* eslint-disable promise/prefer-await-to-then */
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import { requestData, requestDataMsg } from './forms.fixtures';
import * as types from '../../consts';
import { submitForm, SubmissionError } from './forms';
import { mockRequest, mockReset } from '../../../mockRequests';

const middlewares = [thunk];
const mockStore = configureMockStore(middlewares);
const mockRequestData = {
  url: requestData.url,
  method: 'POST',
  data: {
    a: 1,
  },
};

describe('form actions', () => {
  beforeEach(() => {
    document.head.innerHTML = `<meta name="csrf-param" content="authenticity_token" />
     <meta name="csrf-token" content="token123" />`;
  });
  afterEach(() => {
    mockReset();
  });

  it('SubmitForm must include an object item/values', () => {
    expect(() => {
      submitForm();
    }).toThrow();
    expect(() => {
      submitForm({ url: 'http://example.com' });
    }).toThrow();
    expect(() => {
      submitForm({ item: 'Resource' });
    }).toThrow();
    expect(() => {
      submitForm({ values: { a: 1 } });
    }).toThrow();
  });
  it('on failed response raise exception', async () => {
    const store = mockStore({ resources: [] });

    mockRequest({
      ...mockRequestData,
      status: 500,
      response: {
        message: 'oh snap',
      },
    });

    try {
      await store.dispatch(submitForm(requestData));
      throw new Error(
        'Should not hit this then block - test was set up incorrectly'
      );
    } catch (error) {
      expect(error).toBeInstanceOf(SubmissionError);
    }
  });
  it('on failed response handle base errors', async () => {
    const store = mockStore({ resources: [] });

    mockRequest({
      ...mockRequestData,
      status: 404,
      response: {
        message: 'not found',
      },
    });
    try {
      await store.dispatch(submitForm(requestData));
      throw new Error(
        'Should not hit this then block - test was set up incorrectly'
      );
    } catch (error) {
      expect(error).toBeInstanceOf(SubmissionError);
      expect(error.errors._error.errorMsgs[0]).toMatch(
        /Error submitting data: 404*/
      );
    }
  });
  it('on failed response handle field errors', async () => {
    const store = mockStore({ resources: [] });

    mockRequest({
      ...mockRequestData,
      status: 422,
      response: {
        error: { errors: { name: 'already used', base: ['some error'] } },
      },
    });
    try {
      await store.dispatch(submitForm(requestData));
      throw new Error(
        'Should not hit this then block - test was set up incorrectly'
      );
    } catch (error) {
      expect(error).toBeInstanceOf(SubmissionError);
      expect(error.errors).toEqual({
        name: 'already used',
        _error: {
          errorMsgs: ['some error'],
        },
      });
    }
  });
  it('on success dispatch actions correctly', async () => {
    const store = mockStore({ resources: [] });
    const expectedAction = {
      type: 'RESOURCE_FORM_SUBMITTED',
      payload: { item: 'Resource', data: { name: 'xc', id: 70 } },
    };

    mockRequest({
      ...mockRequestData,
      response: {
        name: 'xc',
        id: 70,
      },
    });

    await store.dispatch(submitForm(requestData));
    // dispatch RESOURCE_FORM_SUBMITTED action
    expect(store.getActions()[0]).toEqual(expectedAction);
    // dispatch toast notifications
    expect(store.getActions()[1].type).toEqual(types.TOASTS_ADD);
  });
  it('on success display custom message', async () => {
    const store = mockStore({ resources: [] });

    mockRequest({
      ...mockRequestData,
      response: {
        name: 'random',
        id: 42,
      },
    });
    await store.dispatch(submitForm(requestDataMsg));
    expect(store.getActions()[1].payload.message.message).toEqual(
      'Customized success!'
    );
  });
});
