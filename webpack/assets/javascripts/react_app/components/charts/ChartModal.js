import React, {PropTypes} from 'react';
import { Modal } from 'react-bootstrap';
import c3 from 'c3';

// destroy chart on close
const ChartModal = ({ show, config, onHide, setTitle, title, id }) => {
  function onEnter() {
    const element = document.getElementById(id + 'ModalChart');

    c3.generate({
      bindto: element,
      ...config
    });
    setTitle({
      bindto: element,
      ...config});
  }

  return (
    <Modal show={show}
           enforceFocus={true}
           onHide={onHide}
           onEnter={onEnter}>
      <Modal.Header closeButton>
        <Modal.Title>{title}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <div id={id + 'ModalChart'}>
        </div>
      </Modal.Body>
    </Modal>
  );
};

ChartModal.PropTypes = {
  show: PropTypes.bool.isRequired,
  config: PropTypes.object,
  onHide: PropTypes.func.isRequired,
  setTitle: PropTypes.func.isRequired,
  title: PropTypes.string,
  id: PropTypes.string.isRequired
};

export default ChartModal;
