import React from 'react';
import PropTypes from 'prop-types';
import UUID from 'uuid/v1';
import cx from 'classnames';
import { OverlayTrigger, Tooltip } from 'patternfly-react';
import { translate as __ } from '../../../common/I18n';

const AutoCompleteFocusShortcut = ({ useKeyShortcuts, tooltipID }) => {
  const tooltip = useKeyShortcuts && (
    <Tooltip id={tooltipID}>{__("Press ' / ' to focus on search")}</Tooltip>
  );
  return (
    <OverlayTrigger overlay={tooltip} placement="top" trigger={['hover', 'focus']}>
      <span className={cx('autocomplete-focus-shortcut', !useKeyShortcuts ? 'hide' : '')}>/</span>
    </OverlayTrigger>
  );
};

AutoCompleteFocusShortcut.propTypes = {
  useKeyShortcuts: PropTypes.bool,
  tooltipID: PropTypes.string,
};

AutoCompleteFocusShortcut.defaultProps = {
  useKeyShortcuts: true,
  tooltipID: UUID(),
};

export default AutoCompleteFocusShortcut;
