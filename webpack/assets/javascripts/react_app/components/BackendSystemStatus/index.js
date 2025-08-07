import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { Table, Thead, Tr, Th, Tbody, Td } from '@patternfly/react-table';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListDescription,
  DescriptionListGroup,
  Card,
  CardTitle,
  CardBody,
} from '@patternfly/react-core';
import { computeOverallStatus, flattenPingResults } from './helpers';
import { OKIcon, StatusValue, WarnIcon } from './statusIcons';
import './index.scss';
import { translate as __ } from '../../common/I18n';

const NORMALIZED_TERMS = {
  active: __('active'),
  status: __('status'),
  message: __('message'),
  duration_ms: __('duration (ms)'),
};

const normalizeTerm = term => NORMALIZED_TERMS[term] ?? term;

export const BackendSystemStatus = ({ ping }) => {
  const serviceStatuses = useMemo(() => {
    if (!ping) return [];
    return flattenPingResults(ping);
  }, [ping]);
  const overallStatus = useMemo(() => computeOverallStatus(serviceStatuses), [
    serviceStatuses,
  ]);
  const renderStatusIcon = () => {
    switch (overallStatus) {
      case 'OK':
        return <OKIcon size="md" />;
      case 'FAIL':
        return <WarnIcon size="md" />;
      default:
        return null;
    }
  };

  return (
    <Card ouiaId="backend-system-status" id="backend-system-status">
      <CardTitle>
        {renderStatusIcon()}
        {__('Backend system status')}
      </CardTitle>
      <CardBody>
        <Table
          borders
          isStriped
          variant="compact"
          ouiaId="backend-system-status-table"
        >
          <Thead>
            <Tr ouiaId="bss-header-row">
              <Th>{__('Service name')}</Th>
              <Th>{__('Info')}</Th>
            </Tr>
          </Thead>
          <Tbody>
            {serviceStatuses.map(({ serviceNameParts, data }, index) => {
              // ex: ['foreman', 'cache', 'servers']
              const finalPart = serviceNameParts[serviceNameParts.length - 1]; // 'servers'
              const parentParts = serviceNameParts.slice(0, -1); // ['foreman', 'cache']

              return (
                <Tr key={`${finalPart}-${index}`} ouiaId="bss-table-row">
                  <Td dataLabel="Service name">
                    {/* Separator bullets are handled in CSS */}
                    {parentParts.map(part => (
                      <span key={part} className="service-name-parent">
                        {part}
                      </span>
                    ))}
                    <strong>{finalPart}</strong>
                  </Td>
                  <Td dataLabel="Info">
                    <span className="bss-service-info">
                      <DescriptionList
                        isCompact
                        isHorizontal
                        isAutoColumnWidths
                      >
                        {Object.entries(data).map(([term, desc]) => (
                          <DescriptionListGroup key={term}>
                            <DescriptionListTerm>
                              {normalizeTerm(term)}
                            </DescriptionListTerm>
                            <DescriptionListDescription>
                              <StatusValue val={desc.toString()} />
                            </DescriptionListDescription>
                          </DescriptionListGroup>
                        ))}
                      </DescriptionList>
                    </span>
                  </Td>
                </Tr>
              );
            })}
          </Tbody>
        </Table>
      </CardBody>
    </Card>
  );
};

BackendSystemStatus.propTypes = {
  ping: PropTypes.shape({}),
};

BackendSystemStatus.defaultProps = {
  ping: {},
};

export default BackendSystemStatus;
