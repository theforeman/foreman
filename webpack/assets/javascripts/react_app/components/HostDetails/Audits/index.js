import PropTypes from 'prop-types';
import React from 'react';
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
import { pushUrl } from '../../../../foreman_navigation';

const NUMBER_OF_RECORDS = 3;
const BASE_URL = '/audits';

const AuditCard = ({ hostName }) => {
  const hostSearch = `host=${hostName}`;
  const apiUrl = new URI({
    path: foremanUrl(`/api/${BASE_URL}`),
    query: { search: hostSearch, per_page: NUMBER_OF_RECORDS },
  }).toString();
  const uiUrl = new URI({
    path: foremanUrl(BASE_URL),
    query: { search: hostSearch },
  }).toString();
  const {
    response: { results: audits },
    status = STATUS.PENDING,
  } = useAPI('get', apiUrl);
  return (
    <Card isHoverable>
      <CardHeader>
        <CardTitle>{__('Recent Audits')}</CardTitle>
        <CardActions>
          <a onClick={() => pushUrl(uiUrl)}> {__('All audits')}</a>
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
          {audits && (
            <DataList isCompact>
              {audits.map(
                ({ user_name: user, created_at: timestamp, action, id }) => (
                  <DataListItem key={id}>
                    <DataListItemRow>
                      <DataListItemCells
                        dataListCells={[
                          <DataListCell
                            wrapModifier="truncate"
                            key={`action-${id}`}
                          >
                            <DataListText tooltip={action}>
                              {action}
                            </DataListText>
                          </DataListCell>,
                          <DataListCell
                            wrapModifier="truncate"
                            key={`date-${id}`}
                          >
                            <RelativeDateTime date={timestamp} />
                          </DataListCell>,
                          <DataListCell
                            wrapModifier="truncate"
                            key={`user-${id}`}
                          >
                            <DataListText tooltip={user}>{user}</DataListText>
                          </DataListCell>,
                        ]}
                      />
                    </DataListItemRow>
                  </DataListItem>
                )
              )}
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
