import React, { useEffect } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { TypeAheadSelect } from 'patternfly-react';
import { initialUpdate, updateSelected } from './TypeAheadSelectActions';
import {
  selectTypeAheadSelectExists,
  selectOptions,
  selectSelected,
} from './TypeAheadSelectSelectors';
import reducer from './TypeAheadSelectReducer';

const ConnectedTypeAheadSelect = ({
  id,
  options,
  selected,
  allowNew,
  multiple,
  placeholder,
  defaultInputValue,
  clearButton,
  inputProps,
}) => {
  const dispatch = useDispatch();
  const exists = useSelector(state => selectTypeAheadSelectExists(state, id));

  useEffect(() => {
    if (!exists) {
      dispatch(initialUpdate(options, selected, id));
    }
  }, [dispatch, exists, options, selected, id]);

  const _selected = useSelector(state => selectSelected(state, id));
  const _options = useSelector(state => selectOptions(state, id));
  const onChange = items => dispatch(updateSelected(items, id));

  return (
    <TypeAheadSelect
      id={id}
      options={_options}
      selected={_selected}
      allowNew={allowNew}
      multiple={multiple}
      placeholder={placeholder}
      defaultInputValue={defaultInputValue}
      clearButton={clearButton}
      inputProps={inputProps}
      onChange={onChange}
    />
  );
};

ConnectedTypeAheadSelect.propTypes = {
  id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  options: PropTypes.array,
  selected: PropTypes.array,
  allowNew: PropTypes.bool,
  multiple: PropTypes.bool,
  placeholder: PropTypes.string,
  defaultInputValue: PropTypes.string,
  clearButton: PropTypes.bool,
  inputProps: PropTypes.object,
};

ConnectedTypeAheadSelect.defaultProps = {
  options: [],
  selected: [],
  allowNew: false,
  multiple: false,
  placeholder: '',
  defaultInputValue: '',
  clearButton: false,
  inputProps: {},
};

export default ConnectedTypeAheadSelect;

export const reducers = { typeAheadSelect: reducer };
