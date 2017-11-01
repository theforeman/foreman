import React from 'react';
import PropTypes from 'prop-types';
import { Modal } from 'react-bootstrap';
import c3 from 'c3';
import { setTitle } from '../../../services/ChartService';
// destroy chart on close
const ChartModal = ({ show, config, onHide, title }) => {
  if (!config) {
    return <div />;
  }
  function onEnter() {
    c3.generate(config);
    setTitle(config);
  }

  return (
    <Modal show={show} enforceFocus={true} onHide={onHide} onEnter={onEnter}>
      <Modal.Header closeButton>
        <Modal.Title>{title}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <div data-id={config.id} />
      </Modal.Body>
    </Modal>
  );
};

ChartModal.propTypes = {
  show: PropTypes.bool.isRequired,
  config: PropTypes.object,
  onHide: PropTypes.func.isRequired,
  title: PropTypes.string,
};

export default ChartModal;
