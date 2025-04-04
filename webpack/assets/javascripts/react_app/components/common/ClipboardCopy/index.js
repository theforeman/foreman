import React from 'react';
import PropTypes from 'prop-types';
import {
  ClipboardCopy as PFClipboardCopy,
  ClipboardCopyVariant as PFClipboardCopyVariant,
} from '@patternfly/react-core';
import { translate as __ } from '../../../common/I18n';

const ClipboardCopy = ({ text: defaultText, textareaProps }) => (
  <PFClipboardCopy
    hoverTip={__('Copy to clipboard')}
    clickTip={__('Copied to clipboard')}
    isBlock
    variant={PFClipboardCopyVariant.expansion}
    isExpanded
    isReadOnly={textareaProps.readOnly ?? false}
    className={textareaProps.className ?? null}
  >
    {defaultText}
  </PFClipboardCopy>
);

ClipboardCopy.propTypes = {
  text: PropTypes.string.isRequired,
  textareaProps: PropTypes.object,
};

ClipboardCopy.defaultProps = {
  textareaProps: {},
};

export default ClipboardCopy;
