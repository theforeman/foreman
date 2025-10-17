import React from 'react';
import { Button } from '@patternfly/react-core';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../../common/I18n';

const CancelBtn = ({ onCancel, disabled, variant, btnText }) => (
  <Button
    ouiaId="cancel-button"
    variant={variant}
    onClick={onCancel}
    isDisabled={disabled}
    isDanger
  >
    {btnText}
  </Button>
);

CancelBtn.propTypes = {
  onCancel: PropTypes.func.isRequired,
  disabled: PropTypes.bool,
  variant: PropTypes.oneOf(['secondary', 'danger']),
  btnText: PropTypes.string,
};

CancelBtn.defaultProps = {
  disabled: false,
  variant: 'secondary',
  btnText: __('Cancel'),
};

export default CancelBtn;
