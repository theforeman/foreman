import { SubmissionError } from 'redux-form';
import fetch from 'isomorphic-fetch';
import { addToast } from '../toasts';

const fieldErrors = ({ error }) => {
  let errors = error.errors;

  if (errors.base) {
    errors._error = errors.base;
    delete errors.base;
  }
  return new SubmissionError(errors);
};

const checkErrors = response => {
  if (response.ok) {
    return response;
  }
  if (response.status === 422) {
    // Handle invalid form data
    return response.json().then(body => {
      throw fieldErrors(body);
    });
  }
  throw new SubmissionError({
    _error: [
      `${__('Error submitting data:')} ${response.status} ${__(
        response.statusText
      )}`,
    ],
  });
};

const getcsrfToken = () => {
  const token = document.querySelector('meta[name="csrf-token"]');

  if (token) {
    return token.content;
  }
  // fail gracefully when no token is found
  return '';
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
  values,
  csrfToken = getcsrfToken(),
  method = 'post',
}) => {
  verifyProps(item, values);
  return dispatch => {
    return fetch(url, {
      credentials: 'include',
      method,
      headers: {
        'Content-Type': 'application/json',
        Accept: 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      body: JSON.stringify(values),
    })
      .then(checkErrors)
      .then(response => {
        return response
          .json()
          .then(body =>
            dispatch({
              type: `${item.toUpperCase()}_FORM_SUBMITTED`,
              payload: { item, body },
            })
          )
          .then(() =>
            dispatch(
              addToast({
                type: 'success',
                // eslint-disable-next-line no-undef
                message: Jed.sprintf('%s was successfully created.', __(item)),
              })
            )
          );
      })
      .catch(error => {
        throw error;
      });
  };
};
