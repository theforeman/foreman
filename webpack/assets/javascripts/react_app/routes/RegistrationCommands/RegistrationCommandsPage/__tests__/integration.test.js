import React from 'react';
import { Router } from 'react-router-dom';
import thunk from 'redux-thunk'
import IntegrationTestHelper from '../../../../common/IntegrationTestHelper';
import history from '../../../../history';
import * as selectors from '../RegistrationCommandsPageSelectors'
import RegistrationCommandsPage from '../index'
import { APIMiddleware } from '../../../../redux/API';
import apiReducer from '../../../../redux/API/APIReducer';
import { spySelector } from './fixtures'
import ForemanContext from '../../../../Root/Context/ForemanContext';

jest.mock('../../../../components/common/Slot', () => () => (<></>));
jest
  .spyOn(ForemanContext, 'useForemanOrganization')
  .mockReturnValue({ id: 3, title: 'ACME' });
jest
  .spyOn(ForemanContext, 'useForemanLocation')
  .mockReturnValue({ id: 4, title: 'munich' });


spySelector(selectors);

describe('RegistrationCommandsPage integration', () => {
  it('generate command', () => {
    const integrationTestHelper = new IntegrationTestHelper(apiReducer, [thunk,
      APIMiddleware,
    ]);
    const component = integrationTestHelper.mount(<Router history={history}>
      <RegistrationCommandsPage />
    </Router>);
    integrationTestHelper.takeStoreAndLastActionSnapshot('rendered');

    const submitBtn = component.find('#generate_btn').at(0)
    const commandField = component.find('.pf-v5-c-clipboard-copy__expandable-content pre')

    expect(submitBtn.hasClass('pf-m-disabled')).toBe(false);
    expect(commandField.length).toBe(0);

    // check that only current Org and Loc are selectable
    const organizationSelectOptions = component.find('#reg_organization').find('FormSelectOption');
    expect(organizationSelectOptions.length).toBe(2);
    expect(organizationSelectOptions.findWhere((n) => n.prop('value') === 1).length).toBe(0);
    expect(organizationSelectOptions.findWhere((n) => n.prop('value') === 3).length).toBe(2);
    const locationSelectOptions = component.find('#reg_location').find('FormSelectOption');
    expect(locationSelectOptions.length).toBe(2);
    expect(locationSelectOptions.findWhere((n) => n.prop('value') === 2).length).toBe(0);
    expect(locationSelectOptions.findWhere((n) => n.prop('value') === 4).length).toBe(2);

    submitBtn.simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot('generated command');
  });
});
