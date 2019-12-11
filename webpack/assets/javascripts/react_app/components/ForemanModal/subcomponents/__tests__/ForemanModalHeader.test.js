import React from 'react';
import { shallow } from '@theforeman/test';
import { Modal } from 'patternfly-react';
import ForemanModalHeader from '../ForemanModalHeader';
import * as ModalContext from '../../ForemanModalHooks'; // so enzyme test works
import { testComponentSnapshotsWithFixtures } from '../../../../common/testHelpers';

const fixtures = {
  'should render with default markup': {
    title: 'foo',
  },
  'should render with supplied children': {
    title: 'should not be in markup',
    children: <h1>Modal Title</h1>,
  },
};

const contextValues = {
  title: 'modal title passed thru mock context :)',
};

jest
  .spyOn(ModalContext, 'useModalContext')
  .mockImplementation(() => contextValues);

describe('ForemanModal.Header', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(ForemanModalHeader, fixtures);
  });
  describe('data flow', () => {
    it('renders a <Modal.Title> and title prop', () => {
      const wrapper = shallow(<ForemanModalHeader />);
      expect(wrapper.find(Modal.Title)).toHaveLength(1);
      expect(
        wrapper
          .find(Modal.Title)
          .dive()
          .text()
      ).toMatch(contextValues.title);
    });
    it('passes props to PF component using spread', () => {
      const wrapper = shallow(<ForemanModalHeader myCustomProp="hi" />);
      expect(wrapper.find(Modal.Header).prop('myCustomProp')).toEqual('hi');
    });
    it('has a close button by default', () => {
      const closeButtonHtml = `<button type="button" class="close">`;
      const wrapper = shallow(<ForemanModalHeader />);
      expect(wrapper.html()).toEqual(expect.stringContaining(closeButtonHtml));
    });
    it('has no close button if overridden via props', () => {
      const closeButtonHtml = `<button type="button" class="close">`;
      const wrapper = shallow(<ForemanModalHeader closeButton={false} />);
      expect(wrapper.html()).not.toEqual(
        expect.stringContaining(closeButtonHtml)
      );
    });
  });
});
