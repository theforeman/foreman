import React from 'react';
import { Modal } from 'react-bootstrap';

const ChartModal = ({ show, drawChart, onHide, title, id }) => (

    <Modal show={show}
           enforceFocus={true}
           onHide={onHide}
           onEnter={drawChart}>
      <Modal.Header closeButton>
        <Modal.Title>{title}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <div id={id + 'ModalChart'}></div>
      </Modal.Body>
    </Modal>

  );

export default ChartModal;
