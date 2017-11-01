/* eslint-disable no-throw-literal */
const okClass = 'alert alert-success';
const infoClass = 'alert alert-info';
const warningClass = 'alert alert-warning';
const errorClass = 'alert alert-danger';

const getClassByType = type => {
  switch (type) {
    case 'ok':
    case 'notice':
    case 'success':
      return okClass;
    case 'info':
      return infoClass;
    case 'warning':
    case 'danger':
      return warningClass;
    case 'error':
      return errorClass;
    default:
      throw { error: 'unknown alert type ' + type };
  }
};

export default (type, onClose) =>
  `${onClose ? 'alert-dismissable ' : ''} ${getClassByType(type)}`;
