import React, { createRef } from 'react';
import { TextInput, TextArea } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { useSubmitOnEnter } from '../../../common/hooks/useSubmitOnEnter';

const InlineTextInput = ({
  textArea,
  attribute,
  value,
  setInputValue,
  onSubmit,
}) => {
  const inputRef = createRef(null);
  useSubmitOnEnter(inputRef, onSubmit);

  const inputProps = {
    value,
    onChange: v => setInputValue(v),
    onFocus: () => inputRef?.current?.select(),
  };

  return (
    <>
      {textArea ? (
        <TextArea {...inputProps} aria-label={`${attribute} text area`} />
      ) : (
        <TextInput
          {...inputProps}
          ref={inputRef}
          type="text"
          aria-label={`${attribute} text input`}
          ouiaId={`${attribute}-text-input`}
        />
      )}
    </>
  );
};

InlineTextInput.propTypes = {
  textArea: PropTypes.bool,
  attribute: PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
  setInputValue: PropTypes.func.isRequired,
  onSubmit: PropTypes.func.isRequired,
};

InlineTextInput.defaultProps = {
  textArea: false,
};

export default InlineTextInput;
