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
  CardTitle,
  Accordion,
  AccordionItem,
  AccordionContent,
  AccordionToggle,
} from '@patternfly/react-core';
import Skeleton from 'react-loading-skeleton';
import ElipsisWithTooltip from 'react-ellipsis-with-tooltip';
import { translate as __ } from '../../../common/I18n';
import './styles.scss';

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
      <CardTitle component="h4">{__('Parameters')}</CardTitle>
      <CardBody>
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
                <ElipsisWithTooltip>{param.name}</ElipsisWithTooltip>
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
                            <ElipsisWithTooltip>
                              {param.value}
                            </ElipsisWithTooltip>
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
      </CardBody>
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
