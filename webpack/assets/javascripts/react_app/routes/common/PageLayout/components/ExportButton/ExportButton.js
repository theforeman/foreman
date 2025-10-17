import React from 'react';
import { Button } from '@patternfly/react-core';
import PropTypes from 'prop-types';
import { translate as __ } from '../../../../../common/I18n';
import { exportURL } from '../../../../../common/urlHelpers';

const ExportButton = ({ url, title, text }) => (
  <Button
    ouiaId="export-button"
    className="export-csv"
    href={url}
    variant="secondary"
    title={title}
    component="a"
  >
    {text}
  </Button>
);

ExportButton.propTypes = {
  url: PropTypes.string,
  title: PropTypes.string,
  text: PropTypes.string,
};

ExportButton.defaultProps = {
  url: exportURL(),
  title: __('Export to CSV'),
  text: __('Export'),
};

export default ExportButton;
