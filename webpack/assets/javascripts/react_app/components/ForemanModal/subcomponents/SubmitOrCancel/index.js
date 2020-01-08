import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import { submitModal } from './SubmitOrCancelActions';
import SubmitOrCancel from './SubmitOrCancel';

const ConnectedSubmitOrCancel = ({
  isSubmitting,
  onCancel,
  submitProps,
  id,
}) => {
  const dispatch = useDispatch();

  const { submitBtnProps, cancelBtnProps, ...rest } = submitProps;

  const boundOnSubmit = () =>
    dispatch(
      submitModal({
        ...rest,
        closeFn: onCancel,
        id,
      })
    );

  return (
    <SubmitOrCancel
      isSubmitting={isSubmitting}
      onCancel={onCancel}
      onSubmit={boundOnSubmit}
      submitBtnProps={submitBtnProps}
      cancelBtnProps={cancelBtnProps}
    />
  );
};

ConnectedSubmitOrCancel.propTypes = {
  isSubmitting: PropTypes.bool.isRequired,
  submitProps: PropTypes.object,
  onCancel: PropTypes.func.isRequired,
  id: PropTypes.string.isRequired,
};

ConnectedSubmitOrCancel.defaultProps = {
  submitProps: {},
};

export default ConnectedSubmitOrCancel;
