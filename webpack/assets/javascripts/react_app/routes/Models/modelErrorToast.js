import { translate as __ } from '../../common/I18n';

const CUSTOM_DUPLICATE_MODEL_NAME_MESSAGE = __(
  'A model with this name already exists. Please choose a different name.'
);

const getFullMessages = response =>
  // eslint-disable-next-line camelcase
  response?.data?.error?.full_messages?.filter(Boolean) || [];

const hasDuplicateNameError = response => {
  const nameErrors = response?.data?.error?.errors?.name;
  const duplicateAttributeMessage = __('has already been taken');

  if (Array.isArray(nameErrors)) {
    return nameErrors.some(message => message === duplicateAttributeMessage);
  }

  return getFullMessages(response).some(
    message =>
      message.includes(__('Name')) &&
      message.includes(duplicateAttributeMessage)
  );
};

export const modelErrorToast = ({ response, message, statusText } = {}) => {
  if (hasDuplicateNameError(response)) {
    return CUSTOM_DUPLICATE_MODEL_NAME_MESSAGE;
  }

  const fullMessages = getFullMessages(response);
  return (
    fullMessages.join(', ') ||
    response?.data?.error?.message ||
    message ||
    statusText
  );
};
