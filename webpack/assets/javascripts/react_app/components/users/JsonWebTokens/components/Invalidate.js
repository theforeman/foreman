import React from 'react';
import PropTypes from 'prop-types';

import { Button } from 'patternfly-react';

import { translate as __ } from '../../../../common/I18n';
import ForemanModal from '../../../ForemanModal';
import { INVALIDATE_JWT_MODAL_ID } from '../Constants';

const Invalidate = ({ handleSubmit, modalActions }) => (
  <>
    <Button
      bsStyle="danger"
      className="btn-lg"
      onClick={modalActions.setModalOpen}
    >
      {__('Invalidate tokens')}
    </Button>

    <ForemanModal
      id={INVALIDATE_JWT_MODAL_ID}
      title={__('Invalidate JSON web tokens')}
    >
      <ForemanModal.Header />
      {__('Are you sure you want to invalidate all JSON web tokens?')}
      <ForemanModal.Footer>
        <Button bsStyle="primary" onClick={handleSubmit}>
          {__('Invalidate')}
        </Button>
        &nbsp;
        <Button bsStyle="default" onClick={modalActions.setModalClosed}>
          {__('Cancel')}
        </Button>
      </ForemanModal.Footer>
    </ForemanModal>
  </>
);

Invalidate.propTypes = {
  modalActions: PropTypes.object.isRequired,
  handleSubmit: PropTypes.func.isRequired,
};

export default Invalidate;
