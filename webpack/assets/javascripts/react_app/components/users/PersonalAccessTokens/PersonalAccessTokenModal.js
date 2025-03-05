/* eslint-disable max-lines */
import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import {
  DatePicker,
  Modal,
  Radio,
  ModalVariant,
  Button,
  Form,
  FormGroup,
  InputGroup,
  TimePicker,
  TextInput,
  InputGroupItem,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';
import { ExclamationCircleIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../common/I18n';
import {
  selectTokens,
  selectIsSubmitting,
} from './PersonalAccessTokensSelectors';
import { APIActions } from '../../../redux/API';
import { PERSONAL_ACCESS_TOKEN_FORM_SUBMITTED } from './PersonalAccessTokensConstants';
import './personalAccessToken.scss';

const PersonalAccessTokenModal = ({ controller, url }) => {
  const dispatch = useDispatch();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [endsNever, setEndsNever] = useState(true);
  const [isDateTimeDisabled, setIsDateTimeDisabled] = useState(true);
  const [name, setName] = useState('');
  const [date, setDate] = useState('');
  const [isDateValid, setIsDateValid] = useState(true);
  const [time, setTime] = useState('');
  const [isTimeValid, setIsTimeValid] = useState(true);
  const [showNameErrors, setShowNameErrors] = useState(false);

  const isSubmitting = useSelector(selectIsSubmitting);

  const clearDateTimeState = () => {
    setDate('');
    setTime('');
    setIsDateValid(true);
    setIsTimeValid(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setName('');
    setShowNameErrors(false);
    clearDateTimeState();
    setIsDateTimeDisabled(true);
    setEndsNever(true);
  };

  const validateDateChange = newDate => {
    if (!newDate.length) setIsDateValid(true);
    else if (
      newDate.split('-').length === 3 &&
      newDate &&
      !Number.isNaN(new Date(newDate).getTime())
    )
      setIsDateValid(true);
    else setIsDateValid(false);
    setDate(newDate);
  };

  const validateTimeChange = newTime => {
    if (!newTime.length) setIsTimeValid(true);
    else {
      const splitme = newTime.split(':');
      if (
        !(
          splitme.length === 3 &&
          splitme[0].length === 2 &&
          splitme[1].length === 2 &&
          splitme[2].length === 2
        )
      )
        setIsTimeValid(false);
      else if (!Number.isNaN(new Date(`${date} ${newTime}`).getTime()))
        setIsTimeValid(true);
      else setIsTimeValid(false);
    }
    setTime(newTime);
  };

  const tokens = useSelector(state => selectTokens(state));
  const isNameDuplicate = () => tokens.find(obj => obj.name === name);
  const isNameEmpty = () => name.length === 0;

  const nameHelperText = () => {
    if (showNameErrors) {
      if (isNameEmpty()) {
        return __('Fill out the name');
      } else if (isNameDuplicate() !== undefined) {
        return __('Name has already been taken');
      }
    }
    return '';
  };

  const isDateTimeInFuture = () => {
    if (date.length !== 0) {
      const chosenDate = new Date(`${date} ${time}`);
      const currentDate = new Date();
      if (chosenDate.getTime() <= currentDate.getTime()) {
        return false;
      }
      return true;
    }
    return true;
  };

  const formatExpiration = () => {
    if (endsNever) {
      return null;
    }
    return `${date} ${time}`;
  };

  const handleSubmit = () => {
    if (isDateTimeInFuture() && isDateValid && isTimeValid) {
      dispatch(
        APIActions.post({
          key: PERSONAL_ACCESS_TOKEN_FORM_SUBMITTED,
          url,
          params: { name, expires_at: formatExpiration(), controller },
          handleSuccess: ({ data }) => {
            closeModal();
            dispatch({
              type: PERSONAL_ACCESS_TOKEN_FORM_SUBMITTED,
              payload: { item: 'personal_access_token', data },
            });
          },
          successToast: () =>
            __('Personal Access Token was successfully created.'),
          errorToast: ({ response }) =>
            response?.data?.error?.message ||
            response?.message ||
            response?.statusText,
        })
      );
    }
  };
  const nameValidationError =
    showNameErrors && (isNameEmpty() || isNameDuplicate() !== undefined);
  const expiresValidattionError =
    !isDateTimeInFuture() ||
    ((!date.length || !time.length) && endsNever === false);
  return (
    <>
      <Button
        ouiaId="add-personal-access-token-button"
        variant="primary"
        size="sm"
        onClick={() => setIsModalOpen(true)}
      >
        {__('Add Personal Access Token')}
      </Button>
      <Modal
        ouiaId="new-token-modal"
        id="new-token-modal"
        className="token-modal"
        variant={ModalVariant.small}
        title={__('Create Personal Access Token')}
        isOpen={isModalOpen}
        onClose={closeModal}
        actions={[
          <Button
            ouiaId="confirm-button"
            id="confirm-button"
            key="confirm"
            variant="primary"
            onClick={() => {
              handleSubmit();
            }}
            isDisabled={
              isSubmitting ||
              isNameEmpty() ||
              isNameDuplicate() !== undefined ||
              !isDateValid ||
              !isTimeValid ||
              !isDateTimeInFuture() ||
              ((!date.length || !time.length) && endsNever === false)
            }
          >
            {__('Confirm')}
          </Button>,
          <Button
            ouiaId="cancel-button"
            key="cancel"
            variant="link"
            onClick={closeModal}
            isDisabled={isSubmitting}
          >
            {__('Cancel')}
          </Button>,
        ]}
      >
        <Form className="add-personal-access-token-form">
          <FormGroup label={__('Name')} isRequired>
            <TextInput
              ouiaId="personal-token-name"
              aria-label="personal access token name input"
              id="personal-token-name"
              isRequired
              validated={nameHelperText().length ? 'error' : 'default'}
              value={name}
              onChange={(_event, val) => setName(val)}
              onBlur={() => setShowNameErrors(true)}
            />
            {nameValidationError && (
              <FormHelperText>
                <HelperText>
                  <HelperTextItem
                    icon={<ExclamationCircleIcon />}
                    variant="error"
                  >
                    {nameHelperText()}
                  </HelperTextItem>
                </HelperText>
              </FormHelperText>
            )}
          </FormGroup>
          <FormGroup label={__('Expires')}>
            <div className="pf-v5-c-form">
              <FormGroup fieldId="token-expires-never">
                <Radio
                  ouiaId="expires-never"
                  isChecked={endsNever}
                  onChange={() => {
                    clearDateTimeState();
                    setEndsNever(true);
                    setIsDateTimeDisabled(true);
                  }}
                  id="expires-never"
                  label={__('Never')}
                />
              </FormGroup>
              <FormGroup fieldId="token-expires-datetime">
                <Radio
                  ouiaId="expires-at"
                  isChecked={!endsNever}
                  onChange={() => {
                    setEndsNever(false);
                    setIsDateTimeDisabled(false);
                  }}
                  className="token-expires-radio"
                  id="expires-at"
                  label={
                    <div className="token-expires-radio-wrapper">
                      <div className="token-expires-radio-title">
                        {__('At')}
                      </div>
                      <InputGroup>
                        <InputGroupItem>
                          <DatePicker
                            aria-label="expiration date picker"
                            isDisabled={isDateTimeDisabled}
                            value={date}
                            onChange={(_e, v) => validateDateChange(v)}
                            appendTo={() => document.body}
                            invalidFormatText={
                              isDateValid
                                ? ''
                                : __('Enter valid date: YYYY-MM-DD')
                            }
                            // for undisplaying invalidFormatText when changing to 'Never'
                            dateParse={() =>
                              date === ''
                                ? new Date()
                                : date.split('-').length === 3 &&
                                  new Date(`${date}T00:00:00`)
                            }
                          />
                        </InputGroupItem>
                        <InputGroupItem>
                          <TimePicker
                            aria-label="expiration time picker"
                            isDisabled={
                              !isDateValid ||
                              isDateTimeDisabled ||
                              date.length === 0
                            }
                            is24Hour
                            includeSeconds
                            menuAppendTo={() => document.body}
                            placeholder={__('HH:MM:SS')}
                            onChange={(e, v) => validateTimeChange(v)}
                            invalidFormatErrorMessage={__(
                              'Enter valid time: HH:MM:SS'
                            )}
                            invalidMinMaxErrorMessage=""
                            validateTime={() => isTimeValid}
                            inputProps={{
                              validated: isTimeValid ? 'default' : 'error',
                              // for undisplaying time when changing to 'Never'
                              value: time,
                            }}
                          />
                        </InputGroupItem>
                      </InputGroup>
                    </div>
                  }
                />
              </FormGroup>
            </div>
            {expiresValidattionError && (
              <FormHelperText>
                <HelperText>
                  <HelperTextItem
                    icon={<ExclamationCircleIcon />}
                    variant="error"
                  >
                    {!isDateTimeInFuture()
                      ? __('Cannot be in the past')
                      : __('Fill out the date and time')}
                  </HelperTextItem>
                </HelperText>
              </FormHelperText>
            )}
          </FormGroup>
        </Form>
      </Modal>
    </>
  );
};

PersonalAccessTokenModal.propTypes = {
  url: PropTypes.string.isRequired,
  controller: PropTypes.string,
};
PersonalAccessTokenModal.defaultProps = {
  controller: 'personal_access_tokens',
};

export default PersonalAccessTokenModal;
