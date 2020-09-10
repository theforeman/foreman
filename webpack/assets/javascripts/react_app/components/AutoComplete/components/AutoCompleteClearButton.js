import React from 'react';
import PropTypes from 'prop-types';
import UUID from 'uuid/v1';
import { Icon, OverlayTrigger, Tooltip } from 'patternfly-react';
import { noop } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';

const AutoCompleteClearButton = ({ onClear }) => (
  <OverlayTrigger
    overlay={<Tooltip id={UUID()}>{__('Clear')}</Tooltip>}
    placement="top"
    trigger={['hover', 'focus']}
  >
    <Icon
      name="close"
      className="autocomplete-clear-button"
      onClick={onClear}
    />
  </OverlayTrigger>
);

AutoCompleteClearButton.propTypes = {
  onClear: PropTypes.func,
};

AutoCompleteClearButton.defaultProps = {
  onClear: noop,
};

export default AutoCompleteClearButton;
