import React from 'react';
import { Provider } from 'react-redux';
import { mount } from 'enzyme';
import { generateStore } from '../../redux';
import SearchModal from './SearchModal';

function setup() {
  const props = {
    controller: 'hosts',
    show: true,
    url: '/api/bookmarks',
    onHide: jest.fn(),
  };

  const wrapper = mount(<Provider store={generateStore()}>
      <SearchModal {...props} />
    </Provider>);

  return {
    props,
    wrapper,
  };
}

describe('bookmark modal', () => {
  it('should render the form within a modal', () => {
    const { wrapper } = setup();

    expect(wrapper.find(SearchModal).length).toEqual(1);
  });
  it('should allow closing the modal using the close button', () => {
    const { wrapper, props } = setup();
    wrapper.find('.modal-header button.close').simulate('click');
    expect(props.onHide).toBeCalled();
  });
  it('should allow closing the modal using the cancel button', () => {
    const { wrapper, props } = setup();

    wrapper.find('.form-actions button.btn-default').simulate('click');
    expect(props.onHide).toBeCalled();
  });
});
