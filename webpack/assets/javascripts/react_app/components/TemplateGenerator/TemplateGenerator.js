import React from 'react';
import PropTypes from 'prop-types';
import { Alert, Button } from 'patternfly-react';

import { sprintf, translate as __ } from '../../../react_app/common/I18n';
import AlertBody from '../common/Alert/AlertBody';

const pollingMsg = `
  Report %s is now being generated, the download will start once it's done.
  You can come to this site anytime to get the results.
`;
const doneMsg =
  'Generation of report %s has completed. Download should start automatically. In case it does not, please use download button below.';

const getAlert = (type, msg) => (
  <Alert type={type} title={__('Generating a report')}>
    <AlertBody message={msg} />
  </Alert>
);

class TemplateGenerator extends React.Component {
  getError() {
    const { generationError, generationErrorMessages } = this.props;
    return (
      (generationErrorMessages &&
        generationErrorMessages.map(e => e.message).join('\n')) ||
      generationError
    );
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
    const { polling, dataUrl, generationError } = this.props;

    if (!dataUrl && !polling) return null;

    return (
      <React.Fragment>
        {this.renderAlert()}
        {!polling && !generationError && (
          <div data-turbolinks="false">
            <Button bsStyle="primary" href={dataUrl}>
              {__('Download')}
            </Button>
          </div>
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
  dataUrl: PropTypes.string,
  generationError: PropTypes.string,
  generationErrorMessages: PropTypes.array,
};

TemplateGenerator.defaultProps = {
  polling: false,
  dataUrl: null,
  generationError: null,
  generationErrorMessages: null,
};

export default TemplateGenerator;
