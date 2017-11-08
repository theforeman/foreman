import React from 'react';
import Icon from '../Icon/';
import getAlertClass from './Alert.consts';

const linkMarkup = (title, href) => (
  <div className="pull-right toast-pf-action">
    <a href={href}>{title}</a>
  </div>
);

export default ({
  className = '',
  type,
  children,
  onMouseEnter,
  onMouseLeave,
  onClose,
  link,
  title,
  message,
}) => {
  const CloseButton = ({ onClick }) => (
    <button className="close" aria-hidden="true" onClick={onClick}>
      <Icon type="close" />
    </button>
  );

  return (
    <div
      className={`${getAlertClass(type, onClose)}${className ? ` ${className}` : ''}`}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
    >
      {title && <strong>{title}</strong>}
      {title && <br />}

      {onClose && <CloseButton onClick={onClose} />}
      {link && linkMarkup(link.title, link.href)}
      <span dangerouslySetInnerHTML={{ __html: message }} />
      <Icon type={type} />
      {children}
    </div>
  );
};
