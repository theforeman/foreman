import React from 'react';
import PropTypes from 'prop-types';
import { Modal } from 'patternfly-react';
import { useModalContext } from '../ForemanModalHooks';

const ForemanModalHeader = props => {
  const { title } = useModalContext();
  // title will be falsey if its value is the default ''
  // Render the provided children, or default markup if none given
  return (
    <Modal.Header closeButton {...props}>
      {title && <Modal.Title>{title}</Modal.Title>}
      {props.children}
    </Modal.Header>
  );
};

ForemanModalHeader.propTypes = {
  children: PropTypes.node,
};

ForemanModalHeader.defaultProps = {
  children: null,
};

export default ForemanModalHeader;
