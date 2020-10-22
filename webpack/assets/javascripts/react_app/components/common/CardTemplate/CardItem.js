import PropTypes from 'prop-types';
import React, { useState } from 'react';
import Skeleton from 'react-loading-skeleton';
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
  GridItem,
} from '@patternfly/react-core';

const CardItem = ({ content, header }) => {
  const [activeAccordion, setActiveAccordion] = useState(0);
  const onToggle = id => {
    if (id === activeAccordion) {
      setActiveAccordion('');
    } else {
      setActiveAccordion(id);
    }
  };
  return (
    <GridItem xl2={3} md={6} lg={5}>
      <Card isHoverable>
        <CardBody>{header}</CardBody>
        <Accordion asDefinitionList>
          {!content.length && (
            <div style={{ marginLeft: '20px' }}>
              <Skeleton count={3} width={200} />
            </div>
          )}

          {content.map(item => (
            <AccordionItem key={item.id}>
              <AccordionToggle
                onClick={() => {
                  onToggle(item.name);
                }}
                isExpanded={activeAccordion === item.name}
                id={item.name}
              >
                {item.name}
              </AccordionToggle>
              <AccordionContent
                id={item.name}
                isHidden={activeAccordion !== item.name}
              >
                <DataList aria-label="Parameters" isCompact>
                  <DataListItem aria-labelledby="Parameter's type">
                    <DataListItemRow>
                      <DataListItemCells
                        dataListCells={[
                          <DataListCell key={`${item.name}-type`}>
                            <span>{item.key}</span>
                          </DataListCell>,
                          <DataListCell key={`${item.name}-type-content`}>
                            {item.value}
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
    </GridItem>
  );
};

CardItem.propTypes = {
  content: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string,
      name: PropTypes.string,
      key: PropTypes.string,
      value: PropTypes.string,
    })
  ).isRequired,
  header: PropTypes.string.isRequired,
};

export default CardItem;
