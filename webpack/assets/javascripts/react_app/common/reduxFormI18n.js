import Validators from 'redux-form-validators';
import { sprintf, translate as __ } from '../../react_app/common/I18n';

Validators.formatMessage = (props) => {
  // reusing existing form strings.
  const validations = {
    presence: "can't be blank",
    tooLong: 'is too long (maximum is %s characters)',
  };
  const msg = validations[props.id.replace('form.errors.', '')] || props.defaultMessage;
  if (props.values) {
    // eslint-disable-next-line no-undef
    return sprintf(msg, props.values.count);
  }
  return __(msg);
};
