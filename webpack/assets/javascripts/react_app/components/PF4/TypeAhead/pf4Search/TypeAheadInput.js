import React, { useRef } from 'react';
import PropTypes from 'prop-types';
import { TextInput } from '@patternfly/react-core';
import { SearchIcon } from '@patternfly/react-icons';

import useEventListener from '../../../../common/useEventListener';
import { commonInputPropTypes } from '../helpers/commonPropTypes';

import './TypeAheadInput.scss';

const TypeAheadInput = ({
  onKeyPress,
  onInputFocus,
  passedProps,
  autoSearchEnabled,
}) => {
  const inputRef = useRef(null);
  const { onChange, ...downshiftProps } = passedProps;

  // What patternfly4 expects for args and what downshift creates as a function is different,
  // downshift only expects the event handler
  const onChangeWrapper = (_userValue, event) => onChange(event);

  useEventListener('keydown', onKeyPress, inputRef.current);

  return (
    <React.Fragment>
      <TextInput
        {...downshiftProps}
        ref={inputRef}
        onFocus={onInputFocus}
        aria-label="text input for search"
        onChange={onChangeWrapper}
        className={autoSearchEnabled ? 'foreman-pf4-search-input' : ''}
        type="search"
      />
      {autoSearchEnabled && (
        <SearchIcon size="sm" className="foreman-pf4-search-icon" />
      )}
    </React.Fragment>
  );
};

TypeAheadInput.propTypes = {
  autoSearchEnabled: PropTypes.bool.isRequired,
  ...commonInputPropTypes,
};

export default TypeAheadInput;
