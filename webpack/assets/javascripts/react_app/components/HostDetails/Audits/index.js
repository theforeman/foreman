import PropTypes from 'prop-types';
import React from 'react';
import { useDispatch } from 'react-redux';
import {
  Bullseye,
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  GridItem,
  Title,
} from '@patternfly/react-core';
import {
  Table /* data-codemods */,
  TableText,
  Tr,
  Tbody,
  Td,
} from '@patternfly/react-table';
import URI from 'urijs';
import { push } from 'connected-react-router';

import { foremanUrl } from '../../../common/helpers';
import { translate as __ } from '../../../common/I18n';
import { useAPI } from '../../../common/hooks/API/APIHooks';
import RelativeDateTime from '../../common/dates/RelativeDateTime';
import SkeletonLoader from '../../common/SkeletonLoader';
import { STATUS } from '../../../constants';

const NUMBER_OF_RECORDS = 3;

const AuditCard = ({ hostName }) => {
  const dispatch = useDispatch();
  const hostSearch = `host=${hostName}`;
  const apiUrl = new URI({
    path: foremanUrl('/api/audits'),
    query: { search: hostSearch, per_page: NUMBER_OF_RECORDS },
  }).toString();
  const uiUrl = new URI({
    path: foremanUrl('/audits'),
    query: { search: hostSearch },
  }).toString();
  const {
    response: { results: audits },
    status = STATUS.PENDING,
  } = useAPI('get', apiUrl);
  return (
    <GridItem xl2={3} xl={4} md={6} lg={4}>
      <Card ouiaId="audit-card">
        <CardHeader
          actions={{
            actions: (
              <>
                <a onClick={() => dispatch(push(uiUrl))}> {__('All audits')}</a>
              </>
            ),
            hasNoOffset: false,
            className: undefined,
          }}
        >
          <CardTitle>{__('Recent audits')}</CardTitle>
        </CardHeader>
        <CardBody>
          <SkeletonLoader
            skeletonProps={{ count: NUMBER_OF_RECORDS }}
            status={status}
            emptyState={
              <Bullseye>
                <Title ouiaId="no-results-title" headingLevel="h4">
                  {__('No Results found')}
                </Title>
              </Bullseye>
            }
          >
            {audits && (
              <Table
                aria-label="audits table"
                variant="compact"
                borders="compactBorderless"
                ouiaId="audits-table"
              >
                <Tbody>
                  {audits.map(
                    ({
                      user_name: user,
                      created_at: timestamp,
                      action,
                      id,
                    }) => (
                      <Tr key={id} ouiaId={`audit-${id}`}>
                        <Td modifier="truncate" key={`action-${id}`}>
                          <TableText tooltip={action}>{action}</TableText>
                        </Td>
                        <Td modifier="truncate" key={`date-${id}`}>
                          <RelativeDateTime date={timestamp} />
                        </Td>
                        <Td modifier="truncate" key={`user-${id}`}>
                          <TableText tooltip={user}>{user}</TableText>
                        </Td>
                      </Tr>
                    )
                  )}
                </Tbody>
              </Table>
            )}
          </SkeletonLoader>
        </CardBody>
      </Card>
    </GridItem>
  );
};

AuditCard.propTypes = {
  hostName: PropTypes.string,
};

AuditCard.defaultProps = {
  hostName: undefined,
};

export default AuditCard;
