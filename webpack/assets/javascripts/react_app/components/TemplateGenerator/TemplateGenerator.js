import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { Alert, Button } from '@patternfly/react-core';

import { sprintf, translate as __ } from '../../common/I18n';

const pollingMsg = `
  Report %s is now being generated, the download will start once it's done.
  You can come to this page later to get the results. The result is available for 24 hours.
`;
const doneMsg = `
  Generating of the report %s has been completed.
  Download should start automatically.
  In case it does not, please use the download button below.
`;

const AlertBlock = ({ variant, message, links }) => (
  <Alert
    ouiaId="templateGen-alert"
    variant={variant}
    title={__('Generating a report')}
    isInline
    aria-live="polite"
    actionLinks={links}
  >
    <p style={{ whiteSpace: 'pre-line' }}>{message}</p>
  </Alert>
);

const TemplateGenerator = ({
  data: { templateName },
  polling,
  dataUrl,
  generatingError,
  generatingErrorMessages,
}) => {
  const errors = useMemo(() => {
    const joined =
      (generatingErrorMessages &&
        generatingErrorMessages.map(e => e.message).join('\n')) ||
      '';

    return joined || generatingError;
  }, [generatingError, generatingErrorMessages]);

  if (!dataUrl && !polling && !errors) return null;

  if (polling) {
    return (
      <AlertBlock variant="info" message={sprintf(pollingMsg, templateName)} />
    );
  } else if (errors) {
    return <AlertBlock variant="danger" message={errors} />;
  }

  return (
    <>
      <AlertBlock
        variant="success"
        message={sprintf(doneMsg, templateName)}
        links={
          !polling &&
          !generatingError && (
            <Button
              ouiaId="download-btn"
              variant="primary"
              href={dataUrl}
              component="a"
            >
              {__('Download')}
            </Button>
          )
        }
      />
    </>
  );
};

AlertBlock.propTypes = {
  variant: PropTypes.oneOf(['info', 'danger', 'success']).isRequired,
  message: PropTypes.string.isRequired,
  links: PropTypes.node,
};

AlertBlock.defaultProps = {
  links: <></>,
};

TemplateGenerator.propTypes = {
  data: PropTypes.shape({
    templateName: PropTypes.string.isRequired,
  }).isRequired,
  polling: PropTypes.bool,
  dataUrl: PropTypes.string,
  generatingError: PropTypes.string,
  generatingErrorMessages: PropTypes.arrayOf(
    PropTypes.shape({ message: PropTypes.string })
  ),
};

TemplateGenerator.defaultProps = {
  polling: false,
  dataUrl: null,
  generatingError: null,
  generatingErrorMessages: null,
};

export default TemplateGenerator;
