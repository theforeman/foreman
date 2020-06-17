import React from 'react';
import PropTypes from 'prop-types';
import { Alert, Button } from 'patternfly-react';

import { noop } from '../../common/helpers';
import { sprintf, translate as __ } from '../../common/I18n';
import AlertBody from '../common/Alert/AlertBody';

const pollingMsg = `
  Report %s is now being generated, the download will start once it's done.
  You can come to this page later to get the results. The result is available for 24 hours.
`;
const doneMsg = `
  Generating of the report %s has been completed.
  Download should start automatically.
  In case it does not, please use the download button below.
`;

const getAlert = (type, msg) => (
  <Alert type={type} title={__('Generating a report')}>
    <AlertBody message={msg} />
  </Alert>
);

class TemplateGenerator extends React.Component {
  getError() {
    const { generatingError, generatingErrorMessages } = this.props;
    const errors =
      generatingErrorMessages &&
      generatingErrorMessages.map(e => e.message).join('\n');

    return errors || generatingError;
  }

  renderAlert() {
    const {
      polling,
      data: { templateName },
    } = this.props;
    const error = this.getError();
    if (polling) return getAlert('info', sprintf(pollingMsg, templateName));
    if (error) return getAlert('error', error);
    return getAlert('success', sprintf(doneMsg, templateName));
  }

  render() {
    const { polling, dataUrl, pollReportData, generatingError } = this.props;

    if (!dataUrl && !polling) return null;

    return (
      <React.Fragment>
        {this.renderAlert()}
        {!polling && !generatingError && (
          <Button bsStyle="primary" onClick={() => pollReportData(dataUrl)}>
            {__('Download')}
          </Button>
        )}
      </React.Fragment>
    );
  }
}

TemplateGenerator.propTypes = {
  data: PropTypes.shape({
    templateName: PropTypes.string.isRequired,
  }).isRequired,
  polling: PropTypes.bool,
  pollReportData: PropTypes.func,
  dataUrl: PropTypes.string,
  generatingError: PropTypes.string,
  generatingErrorMessages: PropTypes.arrayOf(
    PropTypes.shape({ message: PropTypes.string })
  ),
};

TemplateGenerator.defaultProps = {
  polling: false,
  pollReportData: noop,
  dataUrl: null,
  generatingError: null,
  generatingErrorMessages: null,
};

export default TemplateGenerator;
