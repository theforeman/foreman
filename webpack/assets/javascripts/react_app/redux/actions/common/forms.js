import { APIActions } from '../../API';
import { sprintf, translate as __ } from '../../../../react_app/common/I18n';

export class SubmissionError {
  constructor(errors) {
    this.errors = errors;
  }
}

const fieldErrors = ({ error }) => {
  const { errors, severity } = error;

  if (errors.base) {
    errors._error = {};
    errors._error.errorMsgs = errors.base;
    errors._error.severity = severity;
    delete errors.base;
  }

  return new SubmissionError(errors);
};

export const onError = error => {
  if (error.response.status === 422) {
    // Handle invalid form data
    throw fieldErrors(error.response.data);
  }
  throw new SubmissionError({
    _error: {
      errorMsgs: [
        `${__('Error submitting data:')} ${error.response.status} ${__(
          error.response.statusText
        )}`,
      ],
    },
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
  item,
  url,
  values: params,
  message,
  method = 'post',
  headers,
  customErrorAlert,
  apiActionTypes: actionTypes,
  errorToast,
  successToast,
}) => {
  verifyProps(item, params);
  return async dispatch => {
    const uniqueAPIKey = `${item.toUpperCase()}_FORM_SUBMITTED`;

    const handleError = error => onError(error);

    const handleSuccess = ({ data }) => {
      dispatch({
        type: uniqueAPIKey,
        payload: { item, data },
      });
    };
    const defaultSuccessToast = () =>
      message || sprintf('%s was successfully created.', __(item));

    const defaultErrorToast = error =>
      sprintf(
        __(
          'Oh no! Something went wrong while submitting the form, the server returned the following error: %s'
        ),
        // eslint-disable-next-line camelcase
        error?.response?.data?.error?.full_messages?.join(', ')
      );
    dispatch(
      APIActions[method]({
        key: uniqueAPIKey,
        url,
        headers,
        params,
        actionTypes,
        handleError,
        handleSuccess,
        successToast: successToast || defaultSuccessToast,
        errorToast: customErrorAlert || errorToast,
      })
    );
  };
};
