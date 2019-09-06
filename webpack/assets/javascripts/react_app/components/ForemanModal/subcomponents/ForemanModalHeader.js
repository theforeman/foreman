import React from 'react';
import PropTypes from 'prop-types';
import { Modal } from 'patternfly-react';
import { useModalContext } from '../ForemanModalHooks';

const ForemanModalHeader = props => {
  const childCount = React.Children.count(props.children);
  const { title } = useModalContext();
  // Render the provided children, or default markup if none given
  return (
    <Modal.Header closeButton {...props}>
      {props.children}
      {childCount === 0 && title && <Modal.Title>{title}</Modal.Title>}
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
