import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Form,
  FormGroup,
  TextInput,
  TextArea,
  ActionGroup,
  Button,
} from '@patternfly/react-core';
import { useHistory } from 'react-router-dom';
import { translate as __ } from '../../common/I18n';
import LabelIcon from '../../components/common/LabelIcon';
import { MODELS_PATH } from './constants';

const HARDWARE_MODEL_HELP = __(
  'The class of CPU supplied in this machine. This is primarily used by Sparc Solaris builds and can be left blank for other architectures. The value can be determined on Solaris via uname -m'
);

const VENDOR_CLASS_HELP = __(
  'The class of the machine reported by the Open Boot Prom. This is primarily used by Sparc Solaris builds and can be left blank for other architectures. The value can be determined on Solaris via uname -i|cut -f2 -d,'
);

const INFO_HELP = __(
  'General useful description, for example this kind of hardware needs a special BIOS setup'
);

const ModelForm = ({ initialValues, handleSubmit, isSubmitting }) => {
  const history = useHistory();
  const [values, setValues] = useState(initialValues);

  const handleChange = field => valueOrEvent => {
    const value =
      valueOrEvent && valueOrEvent.target
        ? valueOrEvent.target.value
        : valueOrEvent;

    setValues(prevValues => ({ ...prevValues, [field]: value || '' }));
  };

  const onSubmit = event => {
    event.preventDefault();
    handleSubmit(values);
  };

  const handleCancel = () => {
    history.push(MODELS_PATH);
  };

  const requiredFields = ['name'];

  const isSubmitDisabled = requiredFields.some(
    field => !(values[field] || '').trim()
  );

  return (
    <Form id="model-create-form" isWidthLimited onSubmit={onSubmit}>
      <FormGroup label={__('Name')} isRequired>
        <TextInput
          id="model_name"
          name="model_name"
          type="text"
          ouiaId="model_name-input"
          required
          value={values.name}
          onChange={handleChange('name')}
        />
      </FormGroup>
      <FormGroup
        label={__('Hardware model')}
        labelIcon={<LabelIcon text={HARDWARE_MODEL_HELP} />}
      >
        <TextInput
          id="model_hardware_model"
          name="model_hardware_model"
          type="text"
          ouiaId="model_hardware_model-input"
          value={values.hardware_model}
          onChange={handleChange('hardware_model')}
        />
      </FormGroup>
      <FormGroup
        label={__('Vendor class')}
        labelIcon={<LabelIcon text={VENDOR_CLASS_HELP} />}
      >
        <TextInput
          id="model_vendor_class"
          name="model_vendor_class"
          type="text"
          ouiaId="model_vendor_class-input"
          value={values.vendor_class}
          onChange={handleChange('vendor_class')}
        />
      </FormGroup>
      <FormGroup label={__('Info')} labelIcon={<LabelIcon text={INFO_HELP} />}>
        <TextArea
          id="model_info"
          name="model_info"
          rows={7}
          value={values.info}
          onChange={handleChange('info')}
        />
      </FormGroup>

      <ActionGroup>
        <Button
          variant="primary"
          type="submit"
          ouiaId="model_submit_button"
          isDisabled={isSubmitDisabled || isSubmitting}
        >
          {__('Submit')}
        </Button>
        <Button
          variant="link"
          onClick={handleCancel}
          ouiaId="model_cancel_button"
        >
          {__('Cancel')}
        </Button>
      </ActionGroup>
    </Form>
  );
};

ModelForm.propTypes = {
  initialValues: PropTypes.shape({
    name: PropTypes.string,
    hardware_model: PropTypes.string,
    vendor_class: PropTypes.string,
    info: PropTypes.string,
  }).isRequired,
  handleSubmit: PropTypes.func.isRequired,
  isSubmitting: PropTypes.bool,
};

ModelForm.defaultProps = {
  isSubmitting: false,
};

export default ModelForm;
