import React from 'react';
import PropTypes from 'prop-types';
import { useQuery } from '@apollo/client';
import { get } from 'lodash';
import { Alert } from '@patternfly/react-core';
import RENDERING_STATUS_QUERY from './renderingStatusQuery.gql';
import PageLayout from '../../common/PageLayout/PageLayout';
import RenderingStatus from '../../../components/RenderingStatus';
import { translate as __, sprintf } from '../../../common/I18n';

const RenderingStatusPage = ({
  match: {
    params: { id },
  },
}) => {
  const { loading, error, data } = useQuery(RENDERING_STATUS_QUERY, {
    variables: { id },
  });

  const hostName = get(data, 'renderingStatus.host.name', '');
  const header = loading
    ? ''
    : sprintf(__('Rendering Status for %s'), hostName);

  return (
    <PageLayout header={header} searchable={false} isLoading={loading}>
      {error && <Alert variant="danger" title={error} />}
      {!error && !loading && <RenderingStatus {...data} />}
    </PageLayout>
  );
};

RenderingStatusPage.propTypes = {
  match: PropTypes.shape({
    params: PropTypes.shape({
      id: PropTypes.string.isRequired,
    }).isRequired,
  }).isRequired,
};

export default RenderingStatusPage;
