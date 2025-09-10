import PropTypes from 'prop-types';
import React, { useState, useContext, useEffect } from 'react';
import {
  Card,
  CardHeader,
  CardExpandableContent,
  CardTitle,
  CardBody,
  GridItem,
  Dropdown,
  DropdownList,
  MenuToggle,
} from '@patternfly/react-core';
import { EllipsisVIcon } from '@patternfly/react-icons';

import { CardExpansionContext } from '../../../CardExpansionContext';

const CardTemplate = ({
  header,
  children,
  expandable,
  dropdownItems,
  overrideGridProps,
  overrideDropdownProps,
  masonryLayout,
  ouiaId,
}) => {
  const { cardExpandStates, dispatch, registerCard } = useContext(
    CardExpansionContext
  );
  const cardId =
    typeof header === 'string' || header instanceof String ? header : ouiaId;
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
      <Card
        isExpanded={isExpanded}
        ouiaId={`card-template-${ouiaId || cardId}`}
      >
        <CardHeader
          {...(dropdownItems && {
            actions: {
              actions: (
                <>
                  <Dropdown
                    ouiaId="template-card-dropdown"
                    isOpen={dropdownVisibility}
                    onOpenChange={isOpen => onDropdownToggle(isOpen)}
                    popperProps={{ position: 'right' }}
                    toggle={toggleRef => (
                      <MenuToggle
                        ref={toggleRef}
                        variant="plain"
                        isExpanded={dropdownVisibility}
                        onClick={() => onDropdownToggle(!dropdownVisibility)}
                      >
                        <EllipsisVIcon />
                      </MenuToggle>
                    )}
                    {...overrideDropdownProps}
                    onSelect={onDropdownSelect}
                  >
                    <DropdownList>{dropdownItems}</DropdownList>
                  </Dropdown>
                </>
              ),
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
  ouiaId: PropTypes.string,
};

CardTemplate.defaultProps = {
  children: undefined,
  overrideGridProps: undefined,
  dropdownItems: undefined,
  overrideDropdownProps: {},
  expandable: false,
  masonryLayout: false,
  ouiaId: undefined,
};

export default CardTemplate;
