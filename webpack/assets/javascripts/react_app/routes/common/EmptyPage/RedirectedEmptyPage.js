import PropTypes from 'prop-types';
import React from 'react';
import { Button } from '@patternfly/react-core';
import { useHistory } from 'react-router-dom';
import { SearchIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../common/I18n';
import { visit } from '../../../../foreman_navigation';
import { EmptyStatePattern } from '../../../components/common/EmptyState';

const RedirectedEmptyPage = ({ location: { state = {} } }) => {
  const {
    location: { state: defaultState },
  } = RedirectedEmptyPage.defaultProps;
  const {
    header = defaultState.header,
    body = defaultState.body,
    action,
    secondayActions,
    back = defaultState.back,
  } = state;
  const history = useHistory();
  const primaryAction = action && (
    <Button
      ouiaId="redirected-empty-page-primary-action"
      onClick={() => visit(action.url)}
      variant="primary"
    >
      {action.title}
    </Button>
  );
  const renderSecondaryActions = () =>
    secondayActions?.map(({ title, url }) => (
      <Button
        ouiaId="redirected-empty-page-secondary-action"
        key={title}
        onClick={() => visit(url)}
        variant="link"
      >
        {title}
      </Button>
    ));

  const backButton = back && (
    <Button
      ouiaId="redirected-empty-page-back-button"
      onClick={() => history.goBack()}
      variant="link"
    >
      {__('Return to the last page')}
    </Button>
  );

  return (
    <EmptyStatePattern
      header={header}
      variant="xl"
      icon={<SearchIcon />}
      action={primaryAction}
      description={body}
      secondaryActions={
        <>
          {renderSecondaryActions()}
          {backButton}
        </>
      }
    />
  );
};

RedirectedEmptyPage.propTypes = {
  location: PropTypes.shape({
    state: PropTypes.shape({
      header: PropTypes.string,
      back: PropTypes.bool,
      body: PropTypes.string,
      action: PropTypes.object,
      secondayActions: PropTypes.array,
    }),
  }),
};

RedirectedEmptyPage.defaultProps = {
  location: {
    state: {
      back: true,
      header: __('Resource not found'),
      body: __(
        'Something went wrong and the resource does not exist or there are access permissions needed. Please, contact your administrator if this issue continues'
      ),
      action: undefined,
      secondayActions: [],
    },
  },
};

export default RedirectedEmptyPage;
