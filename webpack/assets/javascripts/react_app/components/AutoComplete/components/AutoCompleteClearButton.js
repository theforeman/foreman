import React from 'react';
import PropTypes from 'prop-types';
import { Icon } from 'patternfly-react';
import { Tooltip } from '@patternfly/react-core';
import { noop } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';

const AutoCompleteClearButton = ({ onClear }) => (
  <Tooltip content={__('Clear')}>
    <Icon
      name="close"
      className="autocomplete-clear-button"
      onClick={onClear}
    />
  </Tooltip>
);

AutoCompleteClearButton.propTypes = {
  onClear: PropTypes.func,
};

AutoCompleteClearButton.defaultProps = {
  onClear: noop,
};

export default AutoCompleteClearButton;
