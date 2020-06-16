import React, { useEffect, useState } from 'react';
import { foremanUrl } from '../../../../foreman_tools';
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
  CardFooter,
} from '@patternfly/react-core';
import { get } from '../../../redux/API';
import { useSelector, useDispatch } from 'react-redux';
import { selectAPIResponse } from '../../../redux/API/APISelectors';
import styles from '@patternfly/react-styles/css/components/DataList/data-list';
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
        {Object.keys(audits).length &&
          audits.results.map((audit, index) => (
            <AccordionItem>
              <AccordionToggle
                onClick={() => {
                  onToggle(`${audit.request_uuid}-${index}`);
                }}
                isExpanded={ativeAccordion === `${audit.request_uuid}-${index}`}
                id={`${audit.request_uuid}-${index}`}
              >
                <span>{`${audit.action} (by ${audit.user_name})`}</span>
              </AccordionToggle>
              <AccordionContent
                // id={audit.identifier}
                isHidden={ativeAccordion !== `${audit.request_uuid}-${index}`}
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
                                  {value && value[0]}
                                </DataListCell>,
                                <DataListCell key={`new-value-${i}`}>
                                  {value && value[1]}
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
          ))}
      </Accordion>
      <CardFooter>
        <Button
          style={{ top: '12px', left: '100px' }}
          component="a"
          href={foremanUrl(`/audits?seach=host+%3D+${hostName}`)}
          target="_blank"
          variant="secondary"
        >
          More Audits...
        </Button>
      </CardFooter>
    </Card>
  );
};

export default AuditCard;
