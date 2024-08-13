import React from 'react';
import PropTypes from 'prop-types';
import { ClipboardCopy } from '@patternfly/react-core';
import { translate as __ } from '../../../../../../react_app/common/I18n';

export const ErrorPresenter = props => (
  <ClipboardCopy
    isReadOnly
    isBlock
    hoverTip={__('Copy')}
    clickTip={__('Copied!')}
    variant="inline-compact"
  >
    {props.errorMessage}
  </ClipboardCopy>
);

ErrorPresenter.propTypes = {
  errorMessage: PropTypes.string,
};

ErrorPresenter.defaultProps = {
  errorMessage: '',
};
