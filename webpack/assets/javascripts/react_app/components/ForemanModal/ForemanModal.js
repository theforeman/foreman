import React from 'react';
import { Modal } from 'patternfly-react';
import PropTypes from 'prop-types';
import ModalContext from './ForemanModalContext';
import ForemanModalHeader from './subcomponents/ForemanModalHeader';
import ForemanModalFooter from './subcomponents/ForemanModalFooter';
import { extractModalNodes } from './helpers';

/**
 * A modal component that provides a standardized layout and context for modals in Foreman.
 * Should not be used in new components. use Patternfy 4 Modal instead.
 * @param {string} id - The ID of the modal.
 * @param {string} [title=''] - The title of the modal. will not be used if a custom header is provided.
 * @param {boolean} [isOpen=false] - Whether the modal is open or not.
 * @param {function} onClose - The function to call when the modal is closed.
 * @param {boolean} [isSubmitting=false] - Whether the modal is currently submitting data or not.
 * @param {Object} [submitProps={}] - Additional props to pass down to the submit button in the footer.
 * @param {ReactNode} [children=null] - The child nodes of the modal.
 * @returns {ReactNode} The rendered modal component.
 */
/*
  Usage example for a custom header and footer:
  <ForemanModal id="custom">
    <ForemanModal.Header>
      <h3>This is a custom header! :)</h3>
    </ForemanModal.Header>
    body content
    <ForemanModal.Footer>
      Custom footer
    </ForemanModal.Footer>
  </ForemanModal>
*/
const ForemanModal = props => {
  const {
    id,
    title,
    onClose,
    isOpen,
    children,
    isSubmitting,
    submitProps,
    ...propsToPassDown
  } = props;
  // Extract header and footer from children, if provided
  const { headerChild, footerChild, otherChildren } = extractModalNodes(
    children
  );
  const context = {
    isOpen,
    onClose,
    isSubmitting,
    id,
    title,
    submitProps,
  };

  const defaultHeader = headerTitle =>
    headerTitle ? <ForemanModalHeader /> : null;
  const headerToRender = headerChild || defaultHeader(title);

  const defaultFooter = subProps =>
    Object.keys(subProps).length !== 0 ? <ForemanModalFooter /> : null;
  const footerToRender = footerChild || defaultFooter(submitProps);

  return (
    <ModalContext.Provider value={context}>
      <Modal
        onHide={onClose}
        show={isOpen}
        className="foreman-modal"
        {...propsToPassDown}
      >
        {headerToRender}
        <Modal.Body>{otherChildren}</Modal.Body>
        {footerToRender}
      </Modal>
    </ModalContext.Provider>
  );
};

ForemanModal.propTypes = {
  children: PropTypes.node,
  title: PropTypes.string,
  id: PropTypes.string.isRequired,
  isOpen: PropTypes.bool,
  onClose: PropTypes.func.isRequired,
  isSubmitting: PropTypes.bool,
  submitProps: PropTypes.object,
};

ForemanModal.defaultProps = {
  children: null,
  isOpen: false,
  title: '',
  isSubmitting: false,
  submitProps: {},
};

export default ForemanModal;
