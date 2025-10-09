import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { ExclamationCircleIcon } from '@patternfly/react-icons';
import {
  Button,
  Form,
  FormGroup,
  TextInput,
  Checkbox,
  ActionGroup,
  HelperText,
  HelperTextItem,
  FormHelperText,
  Icon,
} from '@patternfly/react-core';
import { useDispatch } from 'react-redux';
import { sprintf, translate as __ } from '../../common/I18n';
import { APIActions } from '../../redux/API';
import './bookmarkForm.css';

const BookmarkForm = ({
  url,
  controller,
  searchQuery,
  setModalClosed,
  bookmarks,
}) => {
  const dispatch = useDispatch();
  const existingNames = bookmarks.map(({ name }) => name);

  const NAME_MAX_LENGTH = 255;
  const NAME_MIN_LENGTH = 1;
  const SUCCESS_TYPE = 'success';
  const ERROR_TYPE = 'error';
  const BLANK_ERROR = "Can't be blank";

  const nameTooLongMsg = sprintf(
    __('Name is too long, max %s'),
    NAME_MAX_LENGTH
  );

  const nameExists = __('Name already exists');
  const nameShort = __(BLANK_ERROR);
  const blankInputErrMsg = __(BLANK_ERROR);

  const [name, setName] = useState('');
  const [query, setQuery] = useState(searchQuery);
  const [isPublic, setIsPublic] = useState(true);

  const [nameErrorMsg, setNameErrorMsg] = useState('');
  const [nameValidated, setNameValidated] = useState('');
  const [queryErrorMsg, setQueryErrorMsg] = useState('');
  const [queryValidated, setQueryValidated] = useState('');

  const validateName = value => {
    if (value.length > NAME_MAX_LENGTH) {
      setNameValidated(ERROR_TYPE);
      setNameErrorMsg(nameTooLongMsg);
    } else if (value.length < NAME_MIN_LENGTH) {
      setNameValidated(ERROR_TYPE);
      setNameErrorMsg(nameShort);
    } else if (existingNames.includes(value)) {
      setNameValidated(ERROR_TYPE);
      setNameErrorMsg(nameExists);
    } else {
      setNameValidated(SUCCESS_TYPE);
    }
  };

  const validateQueryLength = value => {
    if (value.length < 1) {
      setQueryValidated(ERROR_TYPE);
      setQueryErrorMsg(blankInputErrMsg);
    } else {
      setQueryValidated(SUCCESS_TYPE);
    }
  };

  const handleSubmit = () => {
    dispatch(
      APIActions.post({
        key: 'BOOKMARKS_FORM_SUBMITTED',
        url,
        params: {
          public: isPublic,
          controller,
          query,
          name,
        },
        handleSuccess: setModalClosed,
        successToast: () => __('Bookmark created.'),
        errorToast: ({ response }) =>
          // eslint-disable-next-line camelcase
          response?.data?.error?.full_messages?.[0] || response,
      })
    );
  };

  const isValidated =
    nameValidated === SUCCESS_TYPE && queryValidated === SUCCESS_TYPE;

  useEffect(() => {
    if (searchQuery !== '') {
      validateQueryLength(query);
    }
  });

  const handleNameChange = (_event, value) => {
    validateName(value);
    setName(value);
  };

  const handleQueryChange = (_event, value) => {
    validateQueryLength(value);
    setQuery(value);
  };

  const handleIsPublicChange = (_event, value) => {
    setIsPublic(value);
  };

  return (
    <>
      <Form>
        <FormGroup label={__('Name')}>
          <TextInput
            ouiaId="name-input"
            id="name-input"
            isRequired
            type="text"
            name="name"
            value={name}
            onChange={handleNameChange}
            validated={nameValidated}
          />
          {nameValidated === ERROR_TYPE && (
            <FormHelperText>
              <HelperText>
                <HelperTextItem
                  icon={
                    <Icon>
                      <ExclamationCircleIcon />
                    </Icon>
                  }
                  variant={nameValidated}
                >
                  {nameErrorMsg}
                </HelperTextItem>
              </HelperText>
            </FormHelperText>
          )}
        </FormGroup>
        <FormGroup label={__('Query')}>
          <TextInput
            ouiaId="query-input"
            id="query-input"
            isRequired
            type="text"
            name="query"
            value={query}
            onChange={handleQueryChange}
            validated={queryValidated}
          />
          {queryValidated === ERROR_TYPE && (
            <FormHelperText>
              <HelperText>
                <HelperTextItem
                  icon={
                    <Icon>
                      <ExclamationCircleIcon />
                    </Icon>
                  }
                  variant={queryValidated}
                >
                  {queryErrorMsg}
                </HelperTextItem>
              </HelperText>
            </FormHelperText>
          )}
        </FormGroup>
        <Checkbox
          ouiaId="isPublic-checkbox"
          id="isPublic-checkbox"
          label={__('Public')}
          isLabelBeforeButton
          isLabelWrapped
          isChecked={isPublic}
          onChange={handleIsPublicChange}
        />
        <ActionGroup>
          <Button
            ouiaId="submit-btn"
            variant="primary"
            isDisabled={!isValidated}
            onClick={handleSubmit}
          >
            {__('Submit')}
          </Button>
          <Button
            ouiaId="cancel-btn"
            variant="secondary"
            onClick={setModalClosed}
          >
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </>
  );
};

BookmarkForm.propTypes = {
  controller: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  setModalClosed: PropTypes.func.isRequired,
  bookmarks: PropTypes.array,
  searchQuery: PropTypes.string.isRequired,
};

BookmarkForm.defaultProps = {
  bookmarks: [],
};

export default BookmarkForm;
