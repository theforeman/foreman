import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import { Tooltip } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';

const AutoCompleteFocusShortcut = ({ useKeyShortcuts }) => (
  <Tooltip content={useKeyShortcuts && __("Press ' / ' to focus on search")}>
    <span
      className={classNames(
        'autocomplete-focus-shortcut',
        !useKeyShortcuts ? 'hide' : ''
      )}
    >
      /
    </span>
  </Tooltip>
);

AutoCompleteFocusShortcut.propTypes = {
  useKeyShortcuts: PropTypes.bool,
};

AutoCompleteFocusShortcut.defaultProps = {
  useKeyShortcuts: false,
};

export default AutoCompleteFocusShortcut;
