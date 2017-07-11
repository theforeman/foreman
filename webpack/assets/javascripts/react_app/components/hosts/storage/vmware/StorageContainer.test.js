import React from 'react';
import { mount } from 'enzyme';
import { vmwareData, hiddenFieldValue } from './StorageContainer.fixtures';
import { getStore } from '../../../../redux';
import StorageContainer from './';

let wrapper = null;

describe('StorageContainer', () => {
  beforeEach(() => {
    global.__ = str => str;
    wrapper = mount(
      <StorageContainer store={getStore()} data={vmwareData} />
    );
  });

  it('render hidden field correctly', () => {
    expect(
      JSON.parse(
        wrapper.find('#scsi_controller_hidden').props().value
      )
    ).toEqual(hiddenFieldValue);
  });

  it('adds a disk when button is clicked', () => {
    expect(
      wrapper.render().find('.disk-container').length
    ).toEqual(1);

    wrapper.find('.btn-add-disk').simulate('click');

    expect(
      wrapper.render().find('.disk-container').length
    ).toEqual(2);
  });

  it('adds a controller when button is clicked', () => {
    expect(
      wrapper.render().find('.controller-container').length
    ).toEqual(1);

    wrapper.find('.btn-add-controller').simulate('click');

    expect(
      wrapper.render().find('.controller-container').length
    ).toEqual(2);
  });

  it('doesnt remove controller when none are selected', () => {
    expect(
      wrapper.render().find('.controller-container').length
    ).toEqual(1);

    wrapper.find('.btn-remove-controller').simulate('click');

    expect(
      wrapper.render().find('.controller-container').length
    ).toEqual(0);
  });

  it('removes controller when one is selected', () => {
    expect(
      wrapper.render().find('.controller-container').length
    ).toEqual(1);

    wrapper.find('.btn-remove-controller').simulate('click');

    expect(
      wrapper.render().find('.controller-container').length
    ).toEqual(0);
  });
});
