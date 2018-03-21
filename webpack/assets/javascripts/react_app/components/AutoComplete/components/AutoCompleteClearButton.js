import React from 'react';
import PropTypes from 'prop-types';
import UUID from 'uuid/v1';
import { Icon, OverlayTrigger, Tooltip } from 'patternfly-react';
import { noop } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';

const AutoCompleteClearButton = ({ onClear, tooltipID }) => {
  const tooltip = <Tooltip id={tooltipID}>{__('Clear')}</Tooltip>;
  return (
    <OverlayTrigger overlay={tooltip} placement="top" trigger={['hover', 'focus']}>
      <Icon name="close" className="autocomplete-clear-button" onClick={onClear} />
    </OverlayTrigger>
  );
};

AutoCompleteClearButton.propTypes = {
  onClear: PropTypes.func,
  tooltipID: PropTypes.string,
};

AutoCompleteClearButton.defaultProps = {
  onClear: noop,
  tooltipID: UUID(),
};

export default AutoCompleteClearButton;
