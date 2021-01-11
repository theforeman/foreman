import React, { useState } from 'react';
import {
  Spinner,
  Text,
  TextVariants,
  Button,
  Split,
  SplitItem,
} from '@patternfly/react-core';
import { TimesIcon, CheckIcon, PencilAltIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import InlineTextInput from './InlineTextInput';
import { translate as __ } from '../../../common/I18n';
import './inlineEdit.scss';

const InlineEdit = ({ onSave, value, textArea, attribute }) => {
  // Tracks input box state
  const [inputValue, setInputValue] = useState(value);
  const [editing, setEditing] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  const onSubmit = async () => {
    setSubmitting(true);
    await onSave(inputValue, attribute);
    setSubmitting(false);
    setEditing(false);
  };

  const onClear = () => {
    setInputValue(value);
    setEditing(false);
  };

  if (submitting) return <Spinner size="sm" />;
  if (editing) {
    return (
      <Split>
        <SplitItem>
          <InlineTextInput
            {...{ textArea, attribute, onSubmit, setInputValue }}
            value={inputValue || ''}
          />
        </SplitItem>
        <SplitItem>
          <Button
            aria-label={`submit ${attribute}`}
            variant="plain"
            onClick={onSubmit}
          >
            <CheckIcon />
          </Button>
        </SplitItem>
        <SplitItem>
          <Button
            aria-label={`clear ${attribute}`}
            variant="plain"
            onClick={onClear}
          >
            <TimesIcon />
          </Button>
        </SplitItem>
      </Split>
    );
  }
  return (
    <Split>
      <SplitItem>
        <Text aria-label={`${attribute} text value`} component={TextVariants.p}>
          {inputValue || <i>{__('None provided')}</i>}
        </Text>
      </SplitItem>
      <SplitItem>
        <Button
          className="foreman-edit-icon"
          aria-label={`edit ${attribute}`}
          variant="plain"
          onClick={() => setEditing(true)}
        >
          <PencilAltIcon />
        </Button>
      </SplitItem>
    </Split>
  );
};

InlineEdit.propTypes = {
  onSave: PropTypes.func.isRequired,
  value: PropTypes.string,
  attribute: PropTypes.string.isRequired, // a backend identifier that can be used in onSave
  textArea: PropTypes.bool, // Is a text area instead of input when editing
};

InlineEdit.defaultProps = {
  textArea: false,
  value: '', // API can return null, so default to empty string
};

export default InlineEdit;
