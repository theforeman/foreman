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

jest.mock('../../../../components/common/Slot', () => () => (<></>));

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
    const commandField = component.find('.pf-c-clipboard-copy__expandable-content pre')

    expect(submitBtn.hasClass('pf-m-disabled')).toBe(false);
    expect(commandField.length).toBe(0);

    submitBtn.simulate('click');
    integrationTestHelper.takeStoreAndLastActionSnapshot('generated command');
  });
});
