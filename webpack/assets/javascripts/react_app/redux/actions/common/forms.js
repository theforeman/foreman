import { APIActions } from '../../API';
import { sprintf, translate as __ } from '../../../../react_app/common/I18n';

const getBaseErrors = ({ error: { errors, severity } }) => {
  let _error;
  if (errors.base) {
    _error = {};
    _error.errorMsgs = errors.base;
    _error.severity = severity;
    delete errors.base;
  }

  return _error;
};

export const prepareErrors = (errors, base) =>
  Object.keys(errors).reduce(
    (memo, key) => {
      const errorMessages = errors[key];

      memo[key] =
        errorMessages && errorMessages.join
          ? errorMessages.join(', ')
          : errorMessages;
      return memo;
    },
    { _error: base }
  );

export const onError = (error, actions) => {
  actions.setSubmitting(false);
  if (error.response?.status === 422) {
    const base = getBaseErrors(error?.response?.data);

    actions.setErrors(
      prepareErrors(error?.response?.data?.error?.errors, base)
    );
  } else {
    actions.setErrors({
      _error: {
        errorMsgs: [
          `${__('Error submitting data:')} ${error.response?.status} ${
            error.response?.statusText && __(error.response?.statusText)
          }`,
        ],
      },
    });
  }
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
  apiActionTypes: actionTypes,
  errorToast,
  successToast,
  actions,
  successCallback,
}) => {
  verifyProps(item, params);
  return (dispatch) => {
    const uniqueAPIKey = `${item.toUpperCase()}_FORM_SUBMITTED`;

    const handleError = (error) => onError(error, actions);

    const handleSuccess = ({ data }) => {
      successCallback();
      dispatch({
        type: uniqueAPIKey,
        payload: { item, data },
      });
    };
    const defaultSuccessToast = () =>
      message || sprintf('%s was successfully created.', __(item));

    const defaultErrorToast = (error) =>
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
        errorToast: errorToast || defaultErrorToast,
      })
    );
  };
};
