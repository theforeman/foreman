import React from 'react';
import { shallow } from '@theforeman/test';
import { Button, Modal } from 'patternfly-react';
import ForemanModalFooter from '../ForemanModalFooter';
import * as ModalContext from '../../ForemanModalHooks'; // so enzyme test works
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

const fixtures = {
  'should render with default markup': {
    title: 'foo',
  },
  'should render with supplied children': {
    title: 'ignored',
    children: <h4>Modal Footer</h4>,
  },
};

const contextValues = {
  onClose: jest.fn(),
};

jest
  .spyOn(ModalContext, 'useModalContext')
  .mockImplementation(() => contextValues);

describe('ForemanModal.Footer', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(ForemanModalFooter, fixtures);
  });
  describe('data flow', () => {
    it('should make onClose available thru context', () => {
      const wrapper = shallow(<ForemanModalFooter />);
      expect(wrapper.find(Button).prop('onClick')).toEqual(
        contextValues.onClose
      );
    });
    it('passes props to PF component using spread', () => {
      const wrapper = shallow(<ForemanModalFooter myCustomProp="hi" />);
      expect(wrapper.find(Modal.Footer).prop('myCustomProp')).toEqual('hi');
    });
  });
});
