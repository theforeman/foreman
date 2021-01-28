import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { Button, OverlayTrigger, Tooltip } from 'patternfly-react';
import UUID from 'uuid/v1';
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
      <OverlayTrigger
        overlay={<Tooltip id={UUID()}>{successMessage}</Tooltip>}
        placement="right"
        trigger={['click']}
        rootClose
      >
        <Button
          onClick={() => navigator.clipboard.writeText(text)}
          bsStyle="default"
          {...buttonProps}
        >
          {buttonText}
        </Button>
      </OverlayTrigger>
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
