import PropTypes from 'prop-types';
import React from 'react';
import { useSelector } from 'react-redux';
import {
  Bullseye,
  DataList,
  Card,
  CardActions,
  CardHeader,
  CardTitle,
  CardBody,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListText,
  DataListCell,
  Title,
} from '@patternfly/react-core';
import URI from 'urijs';

import { foremanUrl } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';
import { useAPI } from '../../../common/hooks/API/APIHooks';
import RelativeDateTime from '../../common/dates/RelativeDateTime';
import SkeletonLoader from '../../common/SkeletonLoader';
import { STATUS } from '../../../constants';
import { visit } from '../../../../foreman_navigation';
import StatusIcon from '../Status/StatusIcon';
import { REPORT_API_OPTIONS } from './constants';
import { selectReportStatuses } from './Selectors';

const NUMBER_OF_RECORDS = 3;

const AuditCard = ({ hostName }) => {
  const url = `/hosts/${hostName}/config_reports`;
  const apiUrl = new URI({
    path: foremanUrl(`/api/${url}`),
    query: { per_page: NUMBER_OF_RECORDS },
  }).toString();
  const {
    response: { results: reports },
    status = STATUS.PENDING,
  } = useAPI('get', apiUrl, REPORT_API_OPTIONS);
  const statuses = useSelector(selectReportStatuses);
  return (
    <Card isHoverable>
      <CardHeader>
        <CardTitle>{__('Recent Reports')}</CardTitle>
        <CardActions>
          <a onClick={() => visit(foremanUrl(url))}> {__('All reports')}</a>
        </CardActions>
      </CardHeader>
      <CardBody>
        <SkeletonLoader
          skeletonProps={{ count: NUMBER_OF_RECORDS }}
          status={status}
          emptyState={
            <Bullseye>
              <Title headingLevel="h4"> {__('No Results found')} </Title>
            </Bullseye>
          }
        >
          {reports && (
            <DataList isCompact>
              {reports.map(({ origin, reported_at: timestamp, id }, idx) => (
                <DataListItem key={id}>
                  <DataListItemRow>
                    <DataListItemCells
                      dataListCells={[
                        <DataListCell
                          wrapModifier="truncate"
                          key={`origin-${id}`}
                        >
                          <DataListText tooltip={origin}>
                            <a href={foremanUrl(`/config_reports/${id}`)}>
                              {origin || __('N/A')}
                            </a>
                          </DataListText>
                        </DataListCell>,
                        <DataListCell
                          wrapModifier="truncate"
                          key={`timestamp-${id}`}
                        >
                          <RelativeDateTime date={timestamp} />
                        </DataListCell>,
                        <DataListCell
                          wrapModifier="truncate"
                          key={`status-${id}`}
                        >
                          <DataListText tooltip={statuses[idx].label}>
                            <StatusIcon
                              label={statuses[idx].label}
                              statusNumber={statuses[idx].status}
                            />
                          </DataListText>
                        </DataListCell>,
                      ]}
                    />
                  </DataListItemRow>
                </DataListItem>
              ))}
            </DataList>
          )}
        </SkeletonLoader>
      </CardBody>
    </Card>
  );
};

AuditCard.propTypes = {
  hostName: PropTypes.string.isRequired,
};

export default AuditCard;
