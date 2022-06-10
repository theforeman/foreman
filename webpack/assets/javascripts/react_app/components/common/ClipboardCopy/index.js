import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button, Icon } from 'patternfly-react';
import { Tooltip, TooltipPosition } from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';
import './clipboard-copy.scss';

const ClipboardCopy = ({
  text: defaultText,
  successMessage,
  buttonText,
  textareaProps,
  buttonProps,
  hideTextarea,
  withCopyIcon,
}) => {
  const [text, setText] = useState(defaultText);

  const clipboardClass = hideTextarea === false ? 'clipboard-copy' : '';
  const iconMarginLeft = buttonText === '' ? '0px' : '5px';

  return (
    <div className={clipboardClass}>
      {hideTextarea === false ? (
        <textarea
          defaultValue={text}
          onChange={({ target: { value } }) => setText(value)}
          {...textareaProps}
        />
      ) : null}
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
          {withCopyIcon && (
            <Icon
              style={{ marginLeft: iconMarginLeft }}
              type="fa"
              name="copy"
            />
          )}
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
  hideTextarea: PropTypes.bool,
  withCopyIcon: PropTypes.bool,
};

ClipboardCopy.defaultProps = {
  buttonText: __('Copy to clipboard'),
  successMessage: __('Copied!'),
  textareaProps: {},
  buttonProps: {},
  hideTextarea: false,
  withCopyIcon: false,
};

export default ClipboardCopy;
