import React from 'react';
import PropTypes from 'prop-types';
import { Modal, Button } from 'patternfly-react';
import { useModalContext } from '../ForemanModalHooks';

const ForemanModalFooter = props => {
  const childCount = React.Children.count(props.children);
  const { onClose } = useModalContext();
  // Render the provided children, or default markup if none given
  return (
    <Modal.Footer {...props}>
      {props.children}
      {childCount === 0 && (
        <Button bsStyle="default" onClick={onClose}>
          Close
        </Button>
      )}
    </Modal.Footer>
  );
};

ForemanModalFooter.propTypes = {
  children: PropTypes.node,
};

ForemanModalFooter.defaultProps = {
  children: null,
};

export default ForemanModalFooter;
