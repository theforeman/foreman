import React from 'react';
import { mount } from '@theforeman/test';

import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';
import DiffModal from '../DiffModal';
import { diffModalMock } from '../DiffModal.fixtures';

const fixtures = {
  'renders diffModal': diffModalMock,
};

describe('DiffModal', () => {
  describe('rendering...', () =>
    testComponentSnapshotsWithFixtures(DiffModal, fixtures));

  describe('triggering..', () => {
    it('should trigger onHide', () => {
      const toggleModal = jest.fn();
      const changeState = jest.fn();
      const component = mount(
        <DiffModal
          {...diffModalMock}
          toggleModal={toggleModal}
          changeViewType={changeState}
        />
      );
      component
        .find('.close')
        .at(0)
        .simulate('click');
      expect(toggleModal).toHaveBeenCalled();
    });
  });
});
