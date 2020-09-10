import { translate as __ } from '../../common/I18n';

export const passwords = {
  username: { password: 'my-user-name', expected: __('Weak') },
  email: { password: 'my-user@email.com', expected: __('Weak') },
  tooShort: { password: '12345', expected: __('Too short') },
  weak: { password: '123456', expected: __('Weak') },
  medium: { password: 'qwedsa', expected: __('Medium') },
  normal: { password: 'QwedsaZx', expected: __('Normal') },
  strong: { password: 'StrongP@$w0rd', expected: __('Strong') },
  veryStrong: { password: '|Kkh)Xeu#T8($"P;', expected: __('Very strong') },
};

export const passwordStrengthData = {
  className: 'some-class-name',
  id: 'some-id',
  name: 'some-name',
  error: 'some-password-error',
  userInputIds: [],
};

export const passwordStrengthDataWithVerify = {
  ...passwordStrengthData,
  verify: {
    name: 'user[password_confirmation]',
    error: 'some-password-confirmation-error',
  },
};

export const passwordStrengthDataWithInputIds = {
  ...passwordStrengthData,
  userInputIds: ['input1', 'input2'],
};

export const passwordStrengthDefaultProps = {
  doesPasswordsMatch: true,
  data: { ...passwordStrengthData },
};
