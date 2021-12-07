import React from 'react';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import { ExclamationCircleIcon } from '@patternfly/react-icons';
import {
  ClipboardCopy,
  ClipboardCopyVariant,
  Grid,
  GridItem,
} from '@patternfly/react-core';

import { translate as __ } from '../../../common/I18n';
import EmptyState from '../EmptyState';
import { foremanUrl } from '../../../common/helpers';
import './index.scss';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
    props.history.listen(() => {
      if (this.state.hasError) {
        this.setState({
          hasError: false,
        });
      }
    });
  }

  componentDidCatch(error, info) {
    this.setState({ hasError: true, error, info });
  }

  render() {
    const { history, children } = this.props;
    const { hasError, error, info } = this.state;

    if (!hasError) return children;

    const description = (
      <>
        <p>
          {__('There was a problem processing the request. Please try again.')}
        </p>
        <p>
          <FormattedMessage
            id="report-issue"
            defaultMessage={__('To report an issue {clickHere}')}
            values={{
              clickHere: (
                <a
                  target="_blank"
                  rel="noopener noreferrer"
                  href={foremanUrl('/links/issues')}
                >
                  {__('click here')}
                </a>
              ),
            }}
          />
        </p>
      </>
    );

    const action = {
      title: __('Return to last page'),
      onClick: history.goBack,
    };

    return (
      <Grid className="error-boundary-foreman-app">
        <GridItem sm={12}>
          <EmptyState
            icon={<ExclamationCircleIcon />}
            header={__('Something went wrong')}
            description={description}
            action={action}
          />
        </GridItem>
        <GridItem sm={8} smOffset={2}>
          <ClipboardCopy isReadOnly variant={ClipboardCopyVariant.expansion}>
            {error.toString()}
            {info.componentStack}
          </ClipboardCopy>
        </GridItem>
      </Grid>
    );
  }
}

ErrorBoundary.propTypes = {
  children: PropTypes.oneOfType([
    PropTypes.arrayOf(PropTypes.node),
    PropTypes.node,
  ]).isRequired,
  history: PropTypes.object.isRequired,
};

export default ErrorBoundary;
