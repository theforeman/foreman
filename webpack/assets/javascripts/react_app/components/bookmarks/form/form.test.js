import toJson from 'enzyme-to-json';
import { mount, shallow } from 'enzyme';
import React from 'react';
import { Provider } from 'react-redux';
import nock from 'nock';
import BookmarkFormContainer, { BookmarkForm } from './';
import { setupIntegrationTest, flushAllPromises } from '../../../IntergrationHelper';
import bookmarks from '../../../redux/reducers/bookmarks/';

function setup() {
  const props = {
    controller: 'hosts',
    url: 'http://localhost/api/bookmarks',
    onCancel: jest.fn(),
  };
  const mockSubmitForm = jest.fn();
  const wrapper = shallow(<BookmarkForm {...props} handleSubmit={mockSubmitForm}/>);

  return {
    props,
    wrapper,
  };
}

describe('bookmark form integration test', () => {
  let store;
  let dispatchSpy;

  beforeEach(() => {
    ({ store, dispatchSpy } = setupIntegrationTest({ bookmarks }));
  });
  it('full flow', async () => {
    nock('http://localhost')
      .post('/api/bookmarks')
      .reply(201, { ok: true, id: 70 });
    const { props } = setup();

    const wrapper = mount(<Provider store={store}>
        <BookmarkFormContainer {...props} />
      </Provider>);
    wrapper
      .find('input [name="name"]')
      .simulate('change', { target: { value: 'Joe' } });
    wrapper
      .find('textarea [name="query"]')
      .simulate('change', { target: { value: 'search' } });
    wrapper
      .find('input [name="publik"]')
      .simulate('change', { target: { value: true } });
    wrapper.find('form').simulate('submit');
    await flushAllPromises();
    expect(dispatchSpy).toHaveBeenCalledWith({
      type: 'BOOKMARK_FORM_SUBMITTED',
      payload: { item: 'Bookmark', body: { ok: true, id: 70 } },
    });
  });
});

describe('bookmark form - unit tests', () => {
  it('should render the entire form', () => {
    const { wrapper } = setup();

    expect(toJson(wrapper)).toMatchSnapshot();
  });
});
