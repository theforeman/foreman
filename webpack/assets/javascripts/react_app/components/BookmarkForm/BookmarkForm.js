import React from 'react';
import PropTypes from 'prop-types';
import * as Yup from 'yup';
import { useDispatch } from 'react-redux';
import { noop } from '../../common/helpers';
import ForemanForm from '../common/forms/ForemanForm';
import TextField from '../common/forms/TextField';
import { translate as __ } from '../../common/I18n';
import { maxLengthMsg, requiredMsg } from '../common/forms/validators';
import { submitForm } from '../../redux/actions/common/forms';

const BookmarkForm = ({
  url,
  controller,
  onCancel,
  searchQuery,
  setModalClosed,
  bookmarks,
}) => {
  const dispatch = useDispatch();
  const existsNamesRegex = new RegExp(
    `^(?!(${bookmarks.map(({ name }) => name).join('|')})$).+`
  );
  const bookmarkFormSchema = Yup.object().shape({
    name: Yup.string()
      .max(...maxLengthMsg(254))
      .required(requiredMsg())
      .matches(existsNamesRegex, {
        excludeEmptyString: true,
        message: __('name already exists'),
      }),
    query: Yup.string()
      .max(...maxLengthMsg(4096))
      .required(requiredMsg()),
  });

  const handleSubmit = (values, actions) =>
    dispatch(
      submitForm({
        url,
        values: { ...values, controller },
        item: 'Bookmarks',
        message: __('Bookmark was successfully created.'),
        successCallback: setModalClosed,
        actions,
      })
    );

  return (
    <ForemanForm
      onSubmit={handleSubmit}
      initialValues={{
        public: true,
        query: searchQuery,
      }}
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
  controller: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
  setModalClosed: PropTypes.func.isRequired,
  bookmarks: PropTypes.array,
  searchQuery: PropTypes.string.isRequired,
};

BookmarkForm.defaultProps = {
  onCancel: noop,
  bookmarks: [],
};

export default BookmarkForm;
