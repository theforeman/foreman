/* eslint-disable no-throw-literal */
/* eslint-disable no-throw-literal */
const okIcon = 'pficon pficon-ok';
const infoIcon = 'pficon pficon-info';
const warningIcon = 'pficon pficon-warning-triangle-o';
const errorIcon = 'pficon pficon-error-circle-o';
const closeIcon = 'pficon pficon-close';
const questionSign = 'glyphicon glyphicon-question-sign';

export default (type) => {
  switch (type) {
    case 'ok':
    case 'notice':
    case 'success':
      return okIcon;
    case 'info':
      return infoIcon;
    case 'warning':
    case 'danger':
      return warningIcon;
    case 'error':
      return errorIcon;
    case 'close':
      return closeIcon;
    case 'question-sign':
      return questionSign;
    default:
      throw { error: `unknown icon type ${type}` };
  }
};
