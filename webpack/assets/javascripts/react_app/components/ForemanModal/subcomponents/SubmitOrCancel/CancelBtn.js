import React from 'react';
import { Button } from 'patternfly-react';
import PropTypes from 'prop-types';

import { translate as __ } from '../../../../common/I18n';

const CancelBtn = ({ onCancel, disabled, bsStyle, btnText }) => (
  <Button bsStyle={bsStyle} onClick={onCancel} disabled={disabled}>
    {btnText}
  </Button>
);

CancelBtn.propTypes = {
  onCancel: PropTypes.func.isRequired,
  disabled: PropTypes.bool,
  bsStyle: PropTypes.string,
  btnText: PropTypes.string,
};

CancelBtn.defaultProps = {
  disabled: false,
  bsStyle: 'default',
  btnText: __('Cancel'),
};

export default CancelBtn;
