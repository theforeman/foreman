import React from 'react';

import IntegrationTestHelper from '../../../../../common/IntegrationTestHelper';
import { vmwareData, hiddenFieldValue } from './StorageContainer.fixtures';
import hostReducers from '../../../../../redux/reducers/hosts';
import StorageContainer from '../';

jest.unmock('jquery');

let helper;
let component = null;

describe('StorageContainer integration test', () => {
  beforeEach(() => {
    helper = new IntegrationTestHelper({ hosts: hostReducers });
    component = helper.mount(<StorageContainer data={vmwareData} />);
  });

  it('render hidden field correctly', () => {
    expect(
      JSON.parse(component.find('#scsi_controller_hidden').props().value)
    ).toEqual(hiddenFieldValue);
  });

  it.each([['disk'], ['controller']])(
    'adds a %s when button is clicked',
    device => {
      expect(component.render().find(`.${device}-container`)).toHaveLength(1);
      component.find(`button.btn-add-${device}`).simulate('click');
      expect(component.render().find(`.${device}-container`)).toHaveLength(2);
    }
  );

  it('removes controller when one is selected', () => {
    expect(component.render().find('.controller-container')).toHaveLength(1);
    component.find('button.btn-remove-controller').simulate('click');
    expect(component.render().find('.controller-container')).toHaveLength(0);
  });

  it('changes controller type when one is selected', () => {
    const cntrlType = () =>
      helper.getState().hosts.storage.vmware.controllers[0].type;

    expect(cntrlType()).toEqual('VirtualLsiLogicController');
    component
      .find('.controller-type-container select')
      .simulate('change', { target: { value: 'ParaVirtualSCSIController' } });
    expect(cntrlType()).toEqual('ParaVirtualSCSIController');
  });
});
