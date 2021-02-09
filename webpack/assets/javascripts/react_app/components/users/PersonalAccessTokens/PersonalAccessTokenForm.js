import React from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import * as Yup from 'yup';
import { Button } from 'patternfly-react';
import UUID from 'uuid/v1';
import ForemanForm from '../../common/forms/ForemanForm';
import TextField from '../../common/forms/TextField';
import ForemanModal from '../../ForemanModal';
import { useForemanModal } from '../../ForemanModal/ForemanModalHooks';
import { maxLengthMsg, requiredMsg } from '../../common/forms/validators';
import { translate as __ } from '../../../common/I18n';
import { submitForm } from '../../../redux/actions/common/forms';
import DateTime from '../../common/forms/DateTime/DateTime';

const MODAL_ID = 'personal-access-tokens-form-modal';

const tokenFormSchema = Yup.object().shape({
  name: Yup.string()
    .max(...maxLengthMsg(254))
    .required(requiredMsg()),
  expires_at: Yup.date().min(new Date(), __('Cannot be in the past')),
});

const PersonalAccessTokenForm = ({ controller, url, initialValues }) => {
  const dispatch = useDispatch();
  const { setModalOpen, setModalClosed } = useForemanModal({
    id: MODAL_ID,
  });

  const handleSubmit = (values, actions) => {
    dispatch(
      submitForm({
        url,
        values: { ...values, controller },
        item: 'personal_access_token',
        message: __('Personal Access Token was successfully created.'),
        actions,
        successCallback: setModalClosed,
      })
    );
  };

  return (
    <p>
      <Button bsStyle="success" className="btn-lg" onClick={setModalOpen}>
        {__('Add Personal Access Token')}
      </Button>

      <ForemanModal id={MODAL_ID} title={__('Create Personal Access Token')}>
        <ForemanModal.Header />
        <ForemanForm
          onSubmit={handleSubmit}
          initialValues={initialValues}
          validationSchema={tokenFormSchema}
          onCancel={setModalClosed}
        >
          <TextField
            name="name"
            type="text"
            label={__('Name')}
            inputClassName="col-md-6"
            required
          />
          <DateTime
            id={UUID()}
            label={__('Expires')}
            isRequired={false}
            inputClassName="col-md-6"
            placement="bottom"
            inputProps={{ name: 'expires_at' }}
            value={null}
          />
        </ForemanForm>
      </ForemanModal>
    </p>
  );
};

PersonalAccessTokenForm.propTypes = {
  url: PropTypes.string.isRequired,
  initialValues: PropTypes.object,
  controller: PropTypes.string,
};
PersonalAccessTokenForm.defaultProps = {
  initialValues: {},
  controller: 'personal_access_tokens',
};

export default PersonalAccessTokenForm;
