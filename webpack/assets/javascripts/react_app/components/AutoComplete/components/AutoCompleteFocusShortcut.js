import React from 'react';
import PropTypes from 'prop-types';
import UUID from 'uuid/v1';
import classNames from 'classnames';
import { OverlayTrigger, Tooltip } from 'patternfly-react';
import { translate as __ } from '../../../common/I18n';

const AutoCompleteFocusShortcut = ({ useKeyShortcuts }) => {
  const tooltip = useKeyShortcuts && (
    <Tooltip id={UUID()}>{__("Press ' / ' to focus on search")}</Tooltip>
  );
  return (
    <OverlayTrigger
      overlay={tooltip}
      placement="top"
      trigger={['hover', 'focus']}
    >
      <span
        className={classNames(
          'autocomplete-focus-shortcut',
          !useKeyShortcuts ? 'hide' : ''
        )}
      >
        /
      </span>
    </OverlayTrigger>
  );
};

AutoCompleteFocusShortcut.propTypes = {
  useKeyShortcuts: PropTypes.bool,
};

AutoCompleteFocusShortcut.defaultProps = {
  useKeyShortcuts: false,
};

export default AutoCompleteFocusShortcut;
