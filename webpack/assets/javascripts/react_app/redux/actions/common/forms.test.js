import { submitForm } from './forms';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import nock from 'nock';
import { SubmissionError } from 'redux-form';
import * as types from '../../consts';

const middlewares = [thunk];
const mockStore = configureMockStore(middlewares);

describe('form actions', () => {
  beforeEach(() => {
    document.head.innerHTML = `<meta name="csrf-param" content="authenticity_token" />
     <meta name="csrf-token" content="token123" />`;
    global.__ = str => str;
  });
  afterEach(() => {
    nock.cleanAll();
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
  it('on failed response raise exception', () => {
    nock('http://localhost')
      .post('/api/resource')
      .reply(500, { message: 'oh snap' });

    const store = mockStore({ resources: [] });

    store
      .dispatch(
        submitForm({
          values: { a: 1 },
          url: 'http://localhost/api/resource',
          item: 'Resource',
        })
      )
      .then(() => {
        throw new Error(
          'Should not hit this then block - test was set up incorrectly'
        );
      })
      .catch(error => {
        expect(error).toBeInstanceOf(SubmissionError);
      });
  });
  it('on failed response handle base errors', () => {
    nock('http://localhost')
      .post('/api/resource')
      .reply(404, { message: 'not found' });

    const store = mockStore({ resources: [] });

    store
      .dispatch(
        submitForm({
          values: { a: 1 },
          url: 'http://localhost/api/resource',
          item: 'Resource',
        })
      )
      .then(() => {
        throw new Error(
          'Should not hit this then block - test was set up incorrectly'
        );
      })
      .catch(error => {
        expect(error).toBeInstanceOf(SubmissionError);
        expect(error.errors).toEqual({
          _error: ['Error submitting data: 404 Not Found'],
        });
      });
  });
  it('on failed response handle field errors', () => {
    nock('http://localhost')
      .post('/api/resource')
      .reply(422, {
        error: { errors: { name: 'already used', base: 'some error' } },
      });

    const store = mockStore({ resources: [] });

    store
      .dispatch(
        submitForm({
          values: { a: 1 },
          url: 'http://localhost/api/resource',
          item: 'Resource',
        })
      )
      .then(() => {
        throw new Error(
          'Should not hit this then block - test was set up incorrectly'
        );
      })
      .catch(error => {
        expect(error).toBeInstanceOf(SubmissionError);
        expect(error.errors).toEqual({
          name: 'already used',
          _error: 'some error',
        });
      });
  });
  it('on success dispatch actions correctly', () => {
    nock('http://localhost')
      .post('/api/resource')
      .reply(201, {
        name: 'xc',
        id: 70,
      });

    const store = mockStore({ resources: [] });
    const expectedAction = {
      type: 'RESOURCE_FORM_SUBMITTED',
      payload: { item: 'Resource', body: { name: 'xc', id: 70 } },
    };

    store
      .dispatch(
        submitForm({
          values: { a: 1 },
          url: 'http://localhost/api/resource',
          item: 'Resource',
        })
      )
      .then(() => {
        // dispatch RESOURCE_FORM_SUBMITTED action
        expect(store.getActions()[0]).toEqual(expectedAction);
        // dispatch toast notifications
        expect(store.getActions()[1].type).toEqual(types.TOASTS_ADD);
      })
      .catch(() => {
        throw new Error(
          'Should not hit this then block - test was set up incorrectly'
        );
      });
  });
});
