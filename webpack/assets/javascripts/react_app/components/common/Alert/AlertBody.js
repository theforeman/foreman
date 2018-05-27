import React from 'react';
import PropTypes from 'prop-types';
import AlertLink from './AlertLink';

const AlertBody = ({ link, title, message, children }) => (
  <span>
    {link && <AlertLink {...link} />}

    {title && <strong>{title}</strong>}

    <span dangerouslySetInnerHTML={{ __html: message }} />

    {children}
  </span>
);

AlertBody.propTypes = {
  message: PropTypes.node,
  link: PropTypes.shape(AlertLink.propTypes),
  title: PropTypes.string,
  children: PropTypes.node,
};

export default AlertBody;
