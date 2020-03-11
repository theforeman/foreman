import PropTypes from 'prop-types';
import React from 'react';
import { Helmet } from 'react-helmet';

const Head = ({ children }) => <Helmet>{children}</Helmet>;

Head.propTypes = {
  children: PropTypes.node.isRequired,
};

export default Head;
