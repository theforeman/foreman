import React from 'react';
import ForemanModal from '../ForemanModal';
import ForemanModalHeader from '../subcomponents/ForemanModalHeader';
import ForemanModalFooter from '../subcomponents/ForemanModalFooter';
import { testComponentSnapshotsWithFixtures } from '../../../common/testHelpers';

// This file is for unit tests of the ForemanModal component

const headerChild = <ForemanModalHeader>this is the header</ForemanModalHeader>;
const footerChild = <ForemanModalFooter>this is the footer</ForemanModalFooter>;
const modalBody = <div>This is the body</div>;
const onClose = jest.fn();

const fixtures = {
  'should render': {
    id: 'render',
    title: 'Test modal',
    isOpen: true,
    onClose,
  },
  'should render closed': {
    id: 'closed',
    title: 'Test modal',
    isOpen: false,
    onClose,
  },
  'renders when header and footer are supplied': {
    id: 'withSuppliedChildren',
    title: 'Test modal',
    children: [headerChild, modalBody, footerChild],
    isOpen: true,
    onClose,
  },
  'renders default header child when title prop is present': {
    id: 'defaultHeaderChild',
    title: 'Test modal',
    children: [modalBody, footerChild],
    isOpen: true,
    onClose,
  },
  'renders the supplied header child when title prop is not present': {
    id: 'customHeaderChild',
    children: [headerChild, modalBody, footerChild],
    isOpen: true,
    onClose,
  },
  'renders without header when neither <ForemanModal.Header> nor title prop are present': {
    id: 'noHeader',
    children: [modalBody, footerChild],
    isOpen: true,
    onClose,
  },
};

describe('ForemanModal', () => {
  describe('rendering', () => {
    testComponentSnapshotsWithFixtures(ForemanModal, fixtures);
  });
});
