import React, { useState } from 'react';
import {
  DataList,
  DataListItem,
  DataListItemRow,
  DataListItemCells,
  DataListCell,
  Card,
  CardBody,
  Accordion,
  AccordionItem,
  AccordionContent,
  AccordionToggle,
} from '@patternfly/react-core';
import { StarIcon } from '@patternfly/react-icons';
import styles from '@patternfly/react-styles/css/components/DataList/data-list';
import { translate as __ } from '../../../common/I18n';

const InterfacesCard = ({ interfaces }) => {
  const [ativeAccordion, setActiveAccordion] = useState(0);
  const onToggle = id => {
    if (id === ativeAccordion) {
      setActiveAccordion('');
    } else {
      setActiveAccordion(id);
    }
  };
  return (
    <Card isHoverable>
      <CardBody>{__('Interfaces')}</CardBody>
      <Accordion asDefinitionList>
        {interfaces.map(Interface => (
          <AccordionItem>
            <AccordionToggle
              onClick={() => {
                onToggle(Interface.identifier);
              }}
              isExpanded={ativeAccordion === Interface.identifier}
              id={Interface.identifier}
            >
              <span>
                {Interface.primary && <StarIcon />} {Interface.identifier}
              </span>
            </AccordionToggle>
            <AccordionContent
              id={Interface.identifier}
              isHidden={ativeAccordion !== Interface.identifier}
            >
              <DataList
                className={styles.modifiers.compact}
                aria-label="Interfaces"
              >
                <DataListItem aria-labelledby="">
                  <DataListItemRow>
                    <DataListItemCells
                      dataListCells={[
                        <DataListCell key={`${Interface.identifier}-ip`}>
                          <span> {__('IP Address')}</span>
                        </DataListCell>,
                        <DataListCell
                          key={`${Interface.identifier}-ip-content`}
                        >
                          {Interface.ip}
                        </DataListCell>,
                      ]}
                    />
                  </DataListItemRow>
                </DataListItem>
                <DataListItem>
                  <DataListItemRow>
                    <DataListItemCells
                      dataListCells={[
                        <DataListCell key={`${Interface.identifier}-ip6`}>
                          <span>{__('IP6 Address')}</span>
                        </DataListCell>,
                        <DataListCell
                          key={`${Interface.identifier}-ip6-content`}
                        >
                          {Interface.ip6}
                        </DataListCell>,
                      ]}
                    />
                  </DataListItemRow>
                </DataListItem>
                <DataListItem>
                  <DataListItemRow>
                    <DataListItemCells
                      dataListCells={[
                        <DataListCell key={`${Interface.identifier}-fqdn`}>
                          <span>{__('FQDN')}</span>
                        </DataListCell>,
                        <DataListCell
                          key={`${Interface.identifier}-fqdn-content`}
                        >
                          {Interface.fqdn}
                        </DataListCell>,
                      ]}
                    />
                  </DataListItemRow>
                </DataListItem>
                <DataListItem>
                  <DataListItemRow>
                    <DataListItemCells
                      dataListCells={[
                        <DataListCell
                          isFilled
                          key={`${Interface.identifier}-type`}
                        >
                          <span>{__('Type')}</span>
                        </DataListCell>,
                        <DataListCell
                          isFilled
                          alignRight
                          key={`${Interface.identifier}-type-content`}
                        >
                          {Interface.type}
                        </DataListCell>,
                      ]}
                    />
                  </DataListItemRow>
                </DataListItem>
                <DataListItem>
                  <DataListItemRow>
                    <DataListItemCells
                      dataListCells={[
                        <DataListCell
                          isFilled
                          key={`${Interface.identifier}-mac`}
                        >
                          <span>MAC</span>
                        </DataListCell>,
                        <DataListCell
                          isFilled
                          alignRight
                          key={`${Interface.identifier}-mac-content`}
                        >
                          {Interface.mac}
                        </DataListCell>,
                      ]}
                    />
                  </DataListItemRow>
                </DataListItem>
              </DataList>
            </AccordionContent>
          </AccordionItem>
        ))}
      </Accordion>
    </Card>
  );
};

export default InterfacesCard;
