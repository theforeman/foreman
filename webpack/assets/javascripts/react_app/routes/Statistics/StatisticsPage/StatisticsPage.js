import React from 'react';
import PropTypes from 'prop-types';
import { Alert } from 'patternfly-react';
import PageLayout from '../../common/PageLayout/PageLayout';
import Statistics from './Statistics/Statistics';
import { translate as __ } from '../../../common/I18n';

const StatisticsPage = ({ statisticsMeta, discussionUrl, ...props }) => (
  <PageLayout header={__('Statistics')} searchable={false}>
    <Alert type="warning">
      <span className="pficon pficon-warning-triangle-o" />
      <strong>This functionality is deprecated </strong>
      <span className="text">
        and will be removed in version 2.2. If you wish continue using it, you
        will need to install the Foreman Statistics plugin when upgrading to
        2.2.
        <a href={discussionUrl} target="_blank" rel="noreferrer">
          Join discussion
        </a>
      </span>
    </Alert>
    <Statistics statisticsMeta={statisticsMeta} {...props} />
  </PageLayout>
);

StatisticsPage.propTypes = {
  statisticsMeta: PropTypes.array,
  discussionUrl: PropTypes.string,
};

StatisticsPage.defaultProps = {
  statisticsMeta: [],
  discussionUrl: '',
};

export default StatisticsPage;
