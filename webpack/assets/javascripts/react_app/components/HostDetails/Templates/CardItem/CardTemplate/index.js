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
  CardTitle,
  CardBody,
  Accordion,
  AccordionItem,
  AccordionContent,
  AccordionToggle,
  GridItem,
} from '@patternfly/react-core';

const CardItem = ({ content, header, children, overrideGridProps }) => {
  const [activeAccordion, setActiveAccordion] = useState(0);

  const onToggle = id => {
    if (id === activeAccordion) {
      setActiveAccordion('');
    } else {
      setActiveAccordion(id);
    }
  };

  return (
    <GridItem xl2={3} md={6} lg={5} {...overrideGridProps}>
      <Card isHoverable>
        <CardTitle>{header}</CardTitle>
        <CardBody>
          {children || (
            <Accordion asDefinitionList>
              {!content.length && (
                <div style={{ marginLeft: '20px' }}>
                  <Skeleton count={3} width={200} />
                </div>
              )}

              {content.map(({ id, name, key, value, href }) => (
                <AccordionItem key={id}>
                  <AccordionToggle
                    onClick={() => {
                      onToggle(id);
                    }}
                    isExpanded={activeAccordion === id}
                    id={id}
                  >
                    {name}
                  </AccordionToggle>
                  <AccordionContent id={id} isHidden={activeAccordion !== id}>
                    <DataList aria-label="Parameters" isCompact>
                      <DataListItem aria-labelledby="Parameter's type">
                        <DataListItemRow>
                          <DataListItemCells
                            dataListCells={[
                              <DataListCell key={`${name}-type`}>
                                <span>
                                  {href ? <a href={href}>{key}</a> : key}
                                </span>
                              </DataListCell>,
                              <DataListCell key={`${name}-type-content`}>
                                {value}
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
          )}
        </CardBody>
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
  header: PropTypes.node.isRequired,
  children: PropTypes.node,
  overrideGridProps: PropTypes.shape({}),
};

CardItem.defaultProps = {
  children: undefined,
  overrideGridProps: undefined,
};

export default CardItem;
