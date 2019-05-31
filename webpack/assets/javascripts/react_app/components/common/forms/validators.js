import { translate as __, sprintf } from '../../../../react_app/common/I18n';

export const maxLengthMsg = number => [
  number,
  sprintf(__('is too long (maximum is %s characters)'), number),
];

export const requiredMsg = () => __("can't be blank");
