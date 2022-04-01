import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button } from 'patternfly-react';
import { Tooltip, TooltipPosition } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import './clipboard-copy.scss';

const ClipboardCopy = ({
  text: defaultText,
  successMessage,
  buttonText,
  textareaProps,
  buttonProps,
}) => {
  const [text, setText] = useState(defaultText);

  return (
    <div className="clipboard-copy">
      <textarea
        defaultValue={text}
        onChange={({ target: { value } }) => setText(value)}
        {...textareaProps}
      />
      <Tooltip
        content={successMessage}
        position={TooltipPosition.right}
        trigger="click"
      >
        <Button
          onClick={() => navigator.clipboard.writeText(text)}
          bsStyle="default"
          {...buttonProps}
        >
          {buttonText}
        </Button>
      </Tooltip>
    </div>
  );
};

ClipboardCopy.propTypes = {
  text: PropTypes.string.isRequired,
  buttonText: PropTypes.string,
  successMessage: PropTypes.string,
  textareaProps: PropTypes.object,
  buttonProps: PropTypes.object,
};

ClipboardCopy.defaultProps = {
  buttonText: __('Copy to clipboard'),
  successMessage: __('Copied!'),
  textareaProps: {},
  buttonProps: {},
};

export default ClipboardCopy;
