import React from 'react';
import ForemanModal from '.';
import { testComponentSnapshotsWithFixtures } from '../../common/testHelpers';

const headerChild = (
  <ForemanModal.Header>this is the header</ForemanModal.Header>
);
const footerChild = (
  <ForemanModal.Footer>this is the footer</ForemanModal.Footer>
);
const modalBody = <div>This is the body</div>;

const fixtures = {
  'should render': {
    isOpen: true,
    title: 'Test modal',
    onClose: jest.fn(),
  },
  'should render closed': {
    isOpen: false,
    title: 'Test modal',
    onClose: jest.fn(),
  },
  'renders when header and footer are supplied': {
    isOpen: true,
    title: 'Test modal',
    onClose: jest.fn(),
    children: [headerChild, modalBody, footerChild],
  },
  'renders header and footer in correct order regardless of ordering of children': {
    isOpen: true,
    title: 'Test modal',
    onClose: jest.fn(),
    children: [modalBody, footerChild, headerChild],
  },
};

describe('ForemanModal', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(ForemanModal, fixtures);
  });
});
