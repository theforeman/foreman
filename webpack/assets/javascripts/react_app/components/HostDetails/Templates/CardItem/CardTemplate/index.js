import PropTypes from 'prop-types';
import React, { useState, useContext, useEffect } from 'react';
import {
  Card,
  CardHeader,
  CardExpandableContent,
  CardTitle,
  CardBody,
  GridItem,
} from '@patternfly/react-core';
import { Dropdown, KebabToggle } from '@patternfly/react-core/deprecated';

import { CardExpansionContext } from '../../../CardExpansionContext';

const CardTemplate = ({
  header,
  children,
  expandable,
  dropdownItems,
  overrideGridProps,
  overrideDropdownProps,
  masonryLayout,
}) => {
  const { cardExpandStates, dispatch, registerCard } = useContext(
    CardExpansionContext
  );
  const cardId = header;
  const [dropdownVisibility, setDropdownVisibility] = useState(false);
  const isExpanded = expandable && cardExpandStates[`${cardId}`] === true;
  const onDropdownToggle = isOpen => setDropdownVisibility(isOpen);
  useEffect(() => {
    if (expandable) registerCard(cardId);
  }, [cardId, registerCard, expandable]);
  const onExpandCallback = () =>
    dispatch({
      type: isExpanded ? 'collapse' : 'expand',
      key: `${cardId}`,
    });
  const onDropdownSelect = event => {
    setDropdownVisibility(prevState => !prevState);
    // https://github.com/eslint/eslint/issues/12822
    // eslint-disable-next-line no-unused-expressions
    overrideDropdownProps?.onSelect?.(event);
  };
  const CardContainer = masonryLayout ? 'div' : GridItem;
  const gridWidthProps = masonryLayout
    ? {}
    : {
        xl2: 3,
        xl: 4,
        md: 6,
        lg: 4,
      };

  return (
    <CardContainer
      {...gridWidthProps}
      {...overrideGridProps}
      className="masonry-item"
    >
      <Card isExpanded={isExpanded} ouiaId={`card-template-${cardId}`}>
        <CardHeader
          {...(dropdownItems && {
            actions: {
              actions: (
                <>
                  <Dropdown
                    ouiaId="template-card-dropdown"
                    toggle={
                      <KebabToggle
                        onToggle={(_event, isOpen) => onDropdownToggle(isOpen)}
                      />
                    }
                    isOpen={dropdownVisibility}
                    dropdownItems={dropdownItems}
                    isPlain
                    position="right"
                    {...overrideDropdownProps}
                    onSelect={onDropdownSelect}
                  />
                </>
              ),
              hasNoOffset: false,
              className: undefined,
            },
          })}
          onExpand={expandable && onExpandCallback}
          isToggleRightAligned
        >
          <CardTitle>{header}</CardTitle>
        </CardHeader>
        {expandable ? (
          <CardExpandableContent>
            <CardBody>{children}</CardBody>
          </CardExpandableContent>
        ) : (
          <CardBody>{children}</CardBody>
        )}
      </Card>
    </CardContainer>
  );
};

CardTemplate.propTypes = {
  header: PropTypes.node.isRequired,
  children: PropTypes.node,
  overrideGridProps: PropTypes.object,
  dropdownItems: PropTypes.arrayOf(PropTypes.node),
  overrideDropdownProps: PropTypes.object,
  expandable: PropTypes.bool,
  masonryLayout: PropTypes.bool,
};

CardTemplate.defaultProps = {
  children: undefined,
  overrideGridProps: undefined,
  dropdownItems: undefined,
  overrideDropdownProps: {},
  expandable: false,
  masonryLayout: false,
};

export default CardTemplate;
