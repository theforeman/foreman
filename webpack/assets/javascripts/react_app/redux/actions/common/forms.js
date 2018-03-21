// eslint-disable-next-line import/no-extraneous-dependencies
import { SubmissionError } from 'redux-form';
import API from '../../../API';
import { addToast } from '../toasts';
import { sprintf, translate as __ } from '../../../../react_app/common/I18n';

const fieldErrors = ({ error }) => {
  const { errors } = error;

  if (errors.base) {
    errors._error = errors.base;
    delete errors.base;
  }
  return new SubmissionError(errors);
};

const onError = (error) => {
  if (error.response.status === 422) {
    // Handle invalid form data
    throw fieldErrors(error.response.data);
  }
  throw new SubmissionError({
    _error: [`${__('Error submitting data:')} ${error.response.status} ${__(error.response.statusText)}`],
  });
};

const verifyProps = (item, values) => {
  if (!item) {
    throw new Error('item must be defined, e.g. Bookmark');
  }
  if (!values) {
    throw new Error('values must be defined');
  }
};

export const submitForm = ({
  item, url, values, message, method = 'post',
}) => {
  verifyProps(item, values);
  return dispatch =>
    API[method](url, values)
      .then(({ data }) => {
        dispatch({
          type: `${item.toUpperCase()}_FORM_SUBMITTED`,
          payload: { item, data },
        });
        dispatch(addToast({
          type: 'success',
          // eslint-disable-next-line no-undef
          message: message || sprintf('%s was successfully created.', __(item)),
        }));
      })
      .catch(onError);
};
