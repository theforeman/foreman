import PropTypes from 'prop-types';
import React, { useState } from 'react';
import Skeleton from 'react-loading-skeleton';
import { ArrowIcon } from '@patternfly/react-icons';
import ElipsisWithTooltip from 'react-ellipsis-with-tooltip';
import {
  Card,
  DataList,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
  CardBody,
  CardTitle,
  Accordion,
  AccordionItem,
  AccordionContent,
  AccordionToggle,
} from '@patternfly/react-core';

import { foremanUrl } from '../../../../foreman_tools';
import { translate as __ } from '../../../common/I18n';
import { useAPI } from '../../../common/hooks/API/APIHooks';

const AuditCard = ({ hostName }) => {
  const [activeAccordion, setActiveAccordion] = useState(0);
  const onToggle = id => {
    if (id === activeAccordion) {
      setActiveAccordion('');
    } else {
      setActiveAccordion(id);
    }
  };

  const url = hostName && foremanUrl(`/api/audits?search=host+%3D+${hostName}`);
  const {
    response: { results },
  } = useAPI('get', url);
  return (
    <Card isHoverable>
      <CardTitle>
        {__('Recent Audits')}{' '}
        <a href={foremanUrl(`/audits?search=host+%3D+${hostName}`)}>
          <ArrowIcon />
        </a>
      </CardTitle>
      <CardBody>
        <Accordion asDefinitionList>
          {!results && (
            <div style={{ marginLeft: '20px' }}>
              <Skeleton count={3} width={200} />
            </div>
          )}
          {results?.map((audit, index) => {
            if (index < 3)
              return (
                <AccordionItem key={index}>
                  <AccordionToggle
                    onClick={() => {
                      onToggle(`${audit.request_uuid}-${index}`);
                    }}
                    isExpanded={
                      activeAccordion === `${audit.request_uuid}-${index}`
                    }
                    id={`${audit.request_uuid}-${index}`}
                  >
                    <span>{`${audit.action} (by ${audit.user_name})`}</span>
                  </AccordionToggle>
                  <AccordionContent
                    isHidden={
                      activeAccordion !== `${audit.request_uuid}-${index}`
                    }
                  >
                    <DataList
                      style={{
                        width: '350px',
                        overflowX: 'hidden',
                      }}
                      isCompact
                      aria-label="Audits"
                    >
                      {audit &&
                        Object.entries(audit.audited_changes).map(
                          ([key, value], i) => (
                            <DataListItem key={`audit-${i}`} aria-labelledby="">
                              <DataListItemRow>
                                <DataListItemCells
                                  dataListCells={[
                                    <DataListCell key={key}>
                                      <span> {key}</span>
                                    </DataListCell>,
                                    <DataListCell
                                      key={`old-value-${i}`}
                                      style={{
                                        width: '350px',
                                        overflowX: 'hidden',
                                      }}
                                    >
                                      {value && (
                                        <ElipsisWithTooltip>
                                          <mark
                                            style={{
                                              backgroundColor: '#FFC0CB',
                                            }}
                                          >
                                            {value[0]}
                                          </mark>
                                        </ElipsisWithTooltip>
                                      )}
                                    </DataListCell>,
                                    <DataListCell
                                      style={{
                                        width: '350px',
                                        overflowX: 'hidden',
                                      }}
                                      key={`new-value-${i}`}
                                    >
                                      {value && (
                                        <mark
                                          style={{
                                            backgroundColor: '#90EE90',
                                          }}
                                        >
                                          {value[1]}
                                        </mark>
                                      )}
                                    </DataListCell>,
                                  ]}
                                />
                              </DataListItemRow>
                            </DataListItem>
                          )
                        )}
                    </DataList>
                  </AccordionContent>
                </AccordionItem>
              );
            return null;
          })}
        </Accordion>
      </CardBody>
    </Card>
  );
};

AuditCard.propTypes = {
  hostName: PropTypes.string,
};
AuditCard.defaultProps = {
  hostName: undefined,
};

export default AuditCard;
