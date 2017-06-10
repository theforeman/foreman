import React from 'react';
import getAlertClass from './Alert.consts';
import Icon from '../Icon/';

export default ({
  className = '',
  type,
  children,
  onMouseEnter,
  onMouseLeave,
  onClose,
  link,
  title,
  message
}) => {
  const linkMarkup = (title, href) => (
    <div className="pull-right toast-pf-action">
      <a href={href}>
        {title}
      </a>
    </div>
  );

  const CloseButton = ({onClick}) => (
    <button className="close" aria-hidden="true" onClick={onClick}>
      <Icon type="close" />
    </button>
  );

  return (
    <div
      className={`${getAlertClass(type, onClose)}${className ? ' ' + className : ''}`}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
    >
    {onClose && <CloseButton onClick={onClose} />}
    <Icon type={type} />
    {title && <strong>{title}</strong>}
    {title && <br />}

      {link && linkMarkup(link.title, link.href)}
      <span dangerouslySetInnerHTML={{__html: message}} />
      {children}
    </div>
  );
};
