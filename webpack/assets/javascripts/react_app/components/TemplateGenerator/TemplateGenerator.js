import React from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'patternfly-react';

import { sprintf, translate as __ } from '../../../react_app/common/I18n';
import AlertBody from '../common/Alert/AlertBody';

const infoMsg =
  'This will generate report %s. Based on its definition, it can take a long time to process.';
const pollingMsg =
  "Report %s is now being generated, the download will start once it's done. In case you don't want to wait, use the following link to come later on for the result.";

const TemplateGenerator = ({ polling, dataUrl, data, ...props }) => (
  <React.Fragment>
    <Alert type="info" title={__('Generating a report')}>
      <AlertBody
        message={sprintf(polling ? pollingMsg : infoMsg, data.templateName)}
      />
    </Alert>
    {polling && <a href={dataUrl}>{dataUrl}</a>}
  </React.Fragment>
);

TemplateGenerator.propTypes = {
  data: PropTypes.shape({
    templateName: PropTypes.string.isRequired,
  }).isRequired,
  polling: PropTypes.bool,
  scheduleInProgress: PropTypes.bool,
  dataUrl: PropTypes.string,
};

TemplateGenerator.defaultProps = {
  scheduleInProgress: false,
  polling: false,
  dataUrl: null,
};

export default TemplateGenerator;
