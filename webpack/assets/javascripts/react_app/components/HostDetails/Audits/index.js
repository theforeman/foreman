import PropTypes from 'prop-types';
import React, { useEffect, useState } from 'react';
import { useSelector, useDispatch } from 'react-redux';
import Skeleton from 'react-loading-skeleton';
import {
  Card,
  DataList,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
  CardBody,
  Accordion,
  AccordionItem,
  AccordionContent,
  AccordionToggle,
  Button,
} from '@patternfly/react-core';
// eslint-disable-next-line import/no-extraneous-dependencies
import styles from '@patternfly/react-styles/css/components/DataList/data-list';

import { foremanUrl } from '../../../../foreman_tools';
import { get } from '../../../redux/API';
import { selectAPIResponse } from '../../../redux/API/APISelectors';
import { translate as __ } from '../../../common/I18n';

const AuditCard = ({ hostName }) => {
  const [ativeAccordion, setActiveAccordion] = useState(0);
  const onToggle = id => {
    if (id === ativeAccordion) {
      setActiveAccordion('');
    } else {
      setActiveAccordion(id);
    }
  };
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(
      get({
        key: 'HOST_DETAILS_AUDITS',
        url: foremanUrl(`/api/audits?search=host+%3D+${hostName}`),
      })
    );
  }, [hostName, dispatch]);
  const audits = useSelector(state =>
    selectAPIResponse(state, 'HOST_DETAILS_AUDITS')
  );

  return (
    <Card isHoverable>
      <CardBody>{__('Last Audits')}</CardBody>
      <Accordion asDefinitionList>
        {!audits.results && (
          <div style={{ marginLeft: '20px' }}>
            <Skeleton count={3} width={200} />
          </div>
        )}
        {audits.results &&
          audits.results.map((audit, index) => {
            if (index < 3)
              return (
                <AccordionItem key={index}>
                  <AccordionToggle
                    onClick={() => {
                      onToggle(`${audit.request_uuid}-${index}`);
                    }}
                    isExpanded={
                      ativeAccordion === `${audit.request_uuid}-${index}`
                    }
                    id={`${audit.request_uuid}-${index}`}
                  >
                    <span>{`${audit.action} (by ${audit.user_name})`}</span>
                  </AccordionToggle>
                  <AccordionContent
                    isHidden={
                      ativeAccordion !== `${audit.request_uuid}-${index}`
                    }
                  >
                    <DataList
                      className={styles.modifiers.compact}
                      aria-label="Audits"
                    >
                      {audit &&
                        Object.entries(audit.audited_changes).map(
                          ([key, value], i) => (
                            <DataListItem aria-labelledby="">
                              <DataListItemRow>
                                <DataListItemCells
                                  dataListCells={[
                                    <DataListCell key={key}>
                                      <span> {key}</span>
                                    </DataListCell>,
                                    <DataListCell key={`old-value-${i}`}>
                                      {value && (
                                        <mark
                                          style={{ backgroundColor: '#FFC0CB' }}
                                        >
                                          {value[0]}
                                        </mark>
                                      )}
                                    </DataListCell>,
                                    <DataListCell key={`new-value-${i}`}>
                                      {value && (
                                        <mark
                                          style={{ backgroundColor: '#90EE90' }}
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
      <Button
        component="a"
        href={foremanUrl(`/audits?seach=host+%3D+${hostName}`)}
        target="_blank"
        variant="link"
      >
        {__('More Audits...')}
      </Button>
    </Card>
  );
};

AuditCard.propTypes = {
  hostName: PropTypes.string.isRequired,
};

export default AuditCard;
