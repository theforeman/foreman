import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import UUID from '@theforeman/vendor/uuid/v1';
import classNames from '@theforeman/vendor/classnames';
import { OverlayTrigger, Tooltip } from '@theforeman/vendor/patternfly-react';
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
  useKeyShortcuts: true,
};

export default AutoCompleteFocusShortcut;
