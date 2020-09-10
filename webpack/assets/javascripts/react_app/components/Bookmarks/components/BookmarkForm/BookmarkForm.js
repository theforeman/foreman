import React from 'react';
import PropTypes from 'prop-types';
import * as Yup from 'yup';

import { noop } from '../../../../common/helpers';
import ForemanForm from '../../../common/forms/ForemanForm';
import TextField from '../../../common/forms/TextField';
import { translate as __ } from '../../../../../react_app/common/I18n';
import { maxLengthMsg, requiredMsg } from '../../../common/forms/validators';

const bookmarkFormSchema = Yup.object().shape({
  name: Yup.string()
    .max(...maxLengthMsg(254))
    .required(requiredMsg()),
  query: Yup.string()
    .max(...maxLengthMsg(4096))
    .required(requiredMsg()),
});

const BookmarkForm = ({
  url,
  submitForm,
  controller,
  onCancel,
  initialValues,
  setModalClosed,
}) => {
  const handleSubmit = async (values, actions) => {
    await submitForm({
      url,
      values: { ...values, controller },
      item: 'Bookmarks',
      message: __('Bookmark was successfully created.'),
    });
    setModalClosed();
  };

  return (
    <ForemanForm
      onSubmit={(values, actions) => handleSubmit(values, actions)}
      initialValues={initialValues}
      validationSchema={bookmarkFormSchema}
      onCancel={onCancel}
    >
      <TextField name="name" type="text" required="true" label={__('Name')} />
      <TextField
        name="query"
        type="textarea"
        required="true"
        label={__('Query')}
        inputClassName="col-md-8"
      />
      <TextField name="public" type="checkbox" label={__('Public')} />
    </ForemanForm>
  );
};

BookmarkForm.propTypes = {
  onCancel: PropTypes.func,
  submitForm: PropTypes.func.isRequired,
  controller: PropTypes.string.isRequired,
  initialValues: PropTypes.object.isRequired,
  url: PropTypes.string.isRequired,
  setModalClosed: PropTypes.func.isRequired,
};

BookmarkForm.defaultProps = {
  onCancel: noop,
};

export default BookmarkForm;
