import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import UUID from '@theforeman/vendor/uuid/v1';
import {
  Icon,
  OverlayTrigger,
  Tooltip,
} from '@theforeman/vendor/patternfly-react';
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
