import React, { useState } from 'react';
import {
  Spinner,
  Content,
  ContentVariants,
  Button,
  Split,
  SplitItem,
  Icon,
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
            icon={
              <Icon>
                <CheckIcon />
              </Icon>
            }
            ouiaId={`submit-${attribute}-button`}
            aria-label={`submit ${attribute}`}
            variant="plain"
            onClick={onSubmit}
          />
        </SplitItem>
        <SplitItem>
          <Button
            icon={
              <Icon>
                <TimesIcon />
              </Icon>
            }
            ouiaId={`clear-${attribute}-button`}
            aria-label={`clear ${attribute}`}
            variant="plain"
            onClick={onClear}
          />
        </SplitItem>
      </Split>
    );
  }
  return (
    <Split>
      <SplitItem>
        <Content
          aria-label={`${attribute} text value`}
          ouiaId={`${attribute}-text`}
          component={ContentVariants.p}
        >
          {inputValue || <i>{__('None provided')}</i>}
        </Content>
      </SplitItem>
      <SplitItem>
        <Button
          icon={
            <Icon>
              <PencilAltIcon />
            </Icon>
          }
          ouiaId={`edit-${attribute}-button`}
          className="foreman-edit-icon"
          aria-label={`edit ${attribute}`}
          variant="plain"
          onClick={() => setEditing(true)}
        />
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
