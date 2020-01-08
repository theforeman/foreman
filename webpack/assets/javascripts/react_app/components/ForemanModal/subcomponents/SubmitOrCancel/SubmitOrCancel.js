import React from 'react';
import PropTypes from 'prop-types';

import SubmitBtn from './SubmitBtn';
import CancelBtn from './CancelBtn';

const SubmitOrCancel = ({
  isSubmitting,
  onCancel,
  onSubmit,
  submitBtnProps,
  cancelBtnProps,
}) => (
  <React.Fragment>
    <SubmitBtn
      onSubmit={onSubmit}
      isSubmitting={isSubmitting}
      {...submitBtnProps}
    />
    <CancelBtn
      onCancel={onCancel}
      disabled={isSubmitting}
      {...cancelBtnProps}
    />
  </React.Fragment>
);

SubmitOrCancel.propTypes = {
  isSubmitting: PropTypes.bool.isRequired,
  onCancel: PropTypes.func.isRequired,
  onSubmit: PropTypes.func.isRequired,
  submitBtnProps: PropTypes.object,
  cancelBtnProps: PropTypes.object,
};

SubmitOrCancel.defaultProps = {
  submitBtnProps: {},
  cancelBtnProps: {},
};

export default SubmitOrCancel;
