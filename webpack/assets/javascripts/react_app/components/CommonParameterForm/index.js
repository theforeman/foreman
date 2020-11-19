import React, { useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import PropTypes from 'prop-types';

import { translate as __ } from '../../common/I18n';
import { STATUS } from '../../constants';
import { post, put } from '../../redux/API';
import { foremanUrl } from '../../../foreman_tools';
import Form from '../common/forms/Form';

import { COMMON_PARAM_FORM } from './CommonParamFormConsts';
import { selectApiStatus } from './CommonParamFormSelectors';
import { formPayload } from './CommonParamFormHelpers';
import './CommonParamForm.scss';

import NameField from './components/NameField';
import TypeField from './components/TypeField';
import ValueField from './components/ValueField';
import HiddenValueField from './components/HiddenValueField';

const CommonParameterForm = ({ id, name, keyType, value, isMasked, isNew }) => {
  const dispatch = useDispatch();
  const apiStatus = useSelector(selectApiStatus);

  const [newName, setNewName] = useState(name || '');
  const [newType, setNewType] = useState(keyType || 'string');
  const [newValue, setNewValue] = useState(value || '');
  const [newIsMasked, setNewIsMasked] = useState(isMasked);
  const [formErrors, setFormErrors] = useState({});

  const handleSubmit = e => {
    e.preventDefault();

    const reqParams = {
      url: foremanUrl(`/common_parameters/${id || ''}`),
      key: COMMON_PARAM_FORM,
      params: formPayload(newName, newType, newValue, newIsMasked),
      handleSuccess: () => {
        window.location.href = foremanUrl('/common_parameters');
      },
      successToast: () =>
        isNew ? __('Successfully created.') : __('Successfully updated.'),
      handleError: error => setFormErrors(error.response.data.errors),
    };

    if (isNew) {
      dispatch(post(reqParams));
    } else {
      dispatch(put(reqParams));
    }
  };

  return (
    <Form
      className="form-horizontal well common-parameter-form"
      onSubmit={e => handleSubmit(e)}
      onCancel={() => {
        window.location.href = foremanUrl('/common_parameters');
      }}
      submitting={apiStatus === STATUS.PENDING}
    >
      <NameField
        value={newName}
        onChange={setNewName}
        error={formErrors.name && formErrors.name[0]}
      />
      <TypeField selectedType={newType} onChange={setNewType} />
      <ValueField
        value={newValue}
        selectedType={newType}
        isMasked={newIsMasked}
        onChange={setNewValue}
        error={formErrors.value && formErrors.value[0]}
      />
      <HiddenValueField value={newIsMasked} onChange={setNewIsMasked} />
    </Form>
  );
};

CommonParameterForm.propTypes = {
  id: PropTypes.number,
  name: PropTypes.string,
  keyType: PropTypes.string,
  value: PropTypes.any,
  isMasked: PropTypes.bool,
  isNew: PropTypes.bool.isRequired,
};

CommonParameterForm.defaultProps = {
  id: undefined,
  name: '',
  keyType: '',
  value: '',
  isMasked: false,
};

export default CommonParameterForm;
