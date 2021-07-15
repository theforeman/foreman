import React from 'react';
import PropTypes from 'prop-types';
import * as Yup from 'yup';

import { Button } from 'patternfly-react';

import ForemanModal from '../../../ForemanModal';
import ForemanForm from '../../../common/forms/ForemanForm';
import DateTime from '../../../common/forms/DateTime/DateTime';
import { GENERATE_JWT_MODAL_ID } from '../Constants';

import { translate as __ } from '../../../../common/I18n';

const Generate = ({ handleSubmit, modalActions }) => {
  const validationSchema = Yup.object().shape({
    expiresAt: Yup.date().min(new Date(), __("Can't be in the past")),
  });

  return (
    <>
      <Button
        bsStyle="success"
        className="btn-lg"
        onClick={modalActions.setModalOpen}
      >
        {__('Generate token')}
      </Button>

      <ForemanModal
        id={GENERATE_JWT_MODAL_ID}
        title={__('Generate JSON web token')}
      >
        <ForemanModal.Header />
        <ForemanForm
          onSubmit={handleSubmit}
          initialValues={{}}
          validationSchema={validationSchema}
          onCancel={modalActions.setModalClosed}
        >
          <DateTime
            id="jwt_expires_at"
            label={__('Expires at')}
            isRequired={false}
            inputClassName="col-md-5"
            placement="bottom"
            inputProps={{
              name: 'expiresAt',
              placeholder: __('Never'),
              autoComplete: 'off',
            }}
            value={null}
          />
        </ForemanForm>
      </ForemanModal>
    </>
  );
};

Generate.propTypes = {
  handleSubmit: PropTypes.func.isRequired,
  modalActions: PropTypes.object.isRequired,
};

export default Generate;
