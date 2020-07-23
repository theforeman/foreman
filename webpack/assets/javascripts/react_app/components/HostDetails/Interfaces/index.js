import PropTypes from 'prop-types';
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
import Skeleton from 'react-loading-skeleton';
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
        {!interfaces.length && (
          <div style={{ marginLeft: '20px' }}>
            <Skeleton count={3} width={200} />
          </div>
        )}
        {interfaces.map(Interface => (
          <AccordionItem key={Interface.id}>
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
              <DataList isCompact aria-label="Interfaces">
                <DataListItem aria-labelledby="ip">
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
                <DataListItem aria-labelledby="ip6">
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
                <DataListItem aria-labelledby="fqdn">
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
                <DataListItem aria-labelledby="type">
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
                <DataListItem aria-labelledby="mac">
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

InterfacesCard.propTypes = {
  interfaces: PropTypes.array,
};
InterfacesCard.defaultProps = {
  interfaces: [],
};

export default InterfacesCard;
