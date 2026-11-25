import { translate as __ } from '../../common/I18n';
import { parseAPIError } from '../../redux/API/APIHelpers';

const CUSTOM_DUPLICATE_MODEL_NAME_MESSAGE = __(
  'A model with this name already exists. Please choose a different name.'
);

const hasDuplicateNameError = error => {
  const parsed = parseAPIError(error);
  const duplicateAttributeMessage = __('has already been taken');

  const nameErrors = parsed.fieldErrors.name;
  if (Array.isArray(nameErrors)) {
    return nameErrors.some(msg => msg === duplicateAttributeMessage);
  }

  return parsed.messages.some(
    msg => msg.includes(__('Name')) && msg.includes(duplicateAttributeMessage)
  );
};

export const modelErrorToast = (error, parsedMessage) => {
  if (hasDuplicateNameError(error)) {
    return CUSTOM_DUPLICATE_MODEL_NAME_MESSAGE;
  }

  return parsedMessage;
};
