import React from 'react';
import ForemanModal, { reducers } from '../index';
import ForemanModalHeader from '../subcomponents/ForemanModalHeader';
import ForemanModalFooter from '../subcomponents/ForemanModalFooter';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

import { setModalOpen, setModalClosed, addModal } from '../ForemanModalActions';

// This file is for integration tests of the Redux-connected ForemanModal component

describe('ForemanModal - integration tests', () => {
  it('should add, open, and close modals as directed by Redux actions', () => {
    const integrationTestHelper = new IntegrationTestHelper(reducers);

    integrationTestHelper.takeStoreSnapshot('initial state');

    integrationTestHelper.store.dispatch(addModal({ id: 'modal1' }));
    integrationTestHelper.store.dispatch(addModal({ id: 'modal2' }));
    integrationTestHelper.store.dispatch(addModal({ id: 'modal3' }));

    const modal1 = integrationTestHelper.mount(
      <ForemanModal id="modal1" title="modal1 title" />
    );
    const modal2 = integrationTestHelper.mount(
      <ForemanModal id="modal2" title="modal1 title" />
    );
    const modal3 = integrationTestHelper.mount(
      <ForemanModal id="modal3" title="modal1 title" />
    );

    // After a Redux action updates the component, this ensures we're looking at
    // the latest version of the React tree after rerender.
    const updateWrappers = () =>
      [modal1, modal2, modal3].forEach(wrapper => wrapper.update());

    integrationTestHelper.takeStoreSnapshot('state after adding 3 modals');

    // Check the show prop of the inner patternfly component
    const isModalShown = modal =>
      modal
        .find('Modal')
        .first()
        .props().show;

    // Modals should not be shown
    updateWrappers();
    expect(isModalShown(modal1)).toEqual(false);
    expect(isModalShown(modal2)).toEqual(false);
    expect(isModalShown(modal3)).toEqual(false);

    // Open modal1
    integrationTestHelper.store.dispatch(setModalOpen({ id: 'modal1' }));
    // Verify state after opening modal1
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'after opening modal1'
    );
    updateWrappers();
    expect(isModalShown(modal1)).toEqual(true);
    expect(isModalShown(modal2)).toEqual(false);
    expect(isModalShown(modal3)).toEqual(false);

    // Open modal2
    integrationTestHelper.store.dispatch(setModalOpen({ id: 'modal2' }));
    // Verify state after opening modal2
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'after opening modal2'
    );
    updateWrappers();
    expect(isModalShown(modal1)).toEqual(true);
    expect(isModalShown(modal2)).toEqual(true);
    expect(isModalShown(modal3)).toEqual(false);

    // Close modal1
    integrationTestHelper.store.dispatch(setModalClosed({ id: 'modal1' }));
    // Verify state after closing modal1
    integrationTestHelper.takeStoreAndLastActionSnapshot(
      'after closing modal1'
    );
    updateWrappers();
    expect(isModalShown(modal1)).toEqual(false);
    expect(isModalShown(modal2)).toEqual(true);
    expect(isModalShown(modal3)).toEqual(false);
  });
});

// these tests have to live in this file because the subcomponents are created in
// index.js and not ForemanModal.js

describe('ForemanModal subcomponents', () => {
  it('has a Header subcomponent', () => {
    expect(ForemanModal.Header).toEqual(ForemanModalHeader);
  });
  it('has a Footer subcomponent', () => {
    expect(ForemanModal.Footer).toEqual(ForemanModalFooter);
  });
});
