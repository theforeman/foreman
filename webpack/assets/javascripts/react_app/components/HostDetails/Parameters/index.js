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
import Skeleton from 'react-loading-skeleton';
import { translate as __ } from '../../../common/I18n';

const ParametersCard = ({ paramters }) => {
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
      <CardBody>{__('Parameters')}</CardBody>
      <Accordion asDefinitionList>
        {!paramters.length && (
          <div style={{ marginLeft: '20px' }}>
            <Skeleton count={3} width={200} />
          </div>
        )}

        {paramters.map(param => (
          <AccordionItem key={param.id}>
            <AccordionToggle
              onClick={() => {
                onToggle(param.name);
              }}
              isExpanded={ativeAccordion === param.name}
              id={param.name}
            >
              {param.name}
            </AccordionToggle>
            <AccordionContent
              id={param.name}
              isHidden={ativeAccordion !== param.name}
            >
              <DataList aria-label="Parameters" isCompact>
                <DataListItem aria-labelledby="Parameter's type">
                  <DataListItemRow>
                    <DataListItemCells
                      dataListCells={[
                        <DataListCell key={`${param.name}-type`}>
                          <span>{__('Type')}</span>
                        </DataListCell>,
                        <DataListCell key={`${param.name}-type-content`}>
                          {param.parameter_type}
                        </DataListCell>,
                      ]}
                    />
                  </DataListItemRow>
                </DataListItem>
                <DataListItem aria-labelledby="Parameter's Value">
                  <DataListItemRow>
                    <DataListItemCells
                      dataListCells={[
                        <DataListCell isFilled key={`${param.name}-value`}>
                          <span>{__('Value')}</span>
                        </DataListCell>,
                        <DataListCell
                          isFilled
                          alignRight
                          key={`${param.name}-value-content`}
                        >
                          {param.value}
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

ParametersCard.propTypes = {
  paramters: PropTypes.array,
};
ParametersCard.defaultProps = {
  paramters: [],
};

export default ParametersCard;
