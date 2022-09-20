import PropTypes from 'prop-types';
import React, { useState, useContext } from 'react';
import {
  Card,
  CardActions,
  CardHeader,
  CardExpandableContent,
  Dropdown,
  KebabToggle,
  CardTitle,
  CardBody,
  GridItem,
  FlexItem,
} from '@patternfly/react-core';

import { CardExpansionContext } from '../../../Tabs/Details';

const CardTemplate = ({
  header,
  children,
  expandable,
  dropdownItems,
  overrideGridProps,
  overrideDropdownProps,
  masonryLayout,
}) => {
  const { cardExpandStates, dispatch, cardIds } = useContext(
    CardExpansionContext
  );
  const cardId = cardIds?.find(id => id.includes(header));
  if (cardIds && !cardId) {
    throw new Error(
      `Unable to find a fill for the card: ${header}. Please use the same name for the card header and the fill key.`
    );
  }
  const [dropdownVisibility, setDropdownVisibility] = useState(false);
  const isExpanded = expandable && cardExpandStates[`${cardId}`] === true;
  const onDropdownToggle = isOpen => setDropdownVisibility(isOpen);
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
  const CardContainer = masonryLayout ? FlexItem : GridItem;
  const gridWidthProps = masonryLayout
    ? {}
    : {
        xl2: 3,
        xl: 4,
        md: 6,
        lg: 4,
      };
  const cardProps = masonryLayout
    ? { style: { width: '24rem', marginTop: '-0.8rem' } }
    : {};

  return (
    <CardContainer {...gridWidthProps} {...overrideGridProps}>
      <Card isExpanded={isExpanded} ouiaId="card-template" {...cardProps}>
        <CardHeader
          onExpand={expandable && onExpandCallback}
          isToggleRightAligned
        >
          {dropdownItems && (
            <CardActions>
              <Dropdown
                ouiaId="template-card-dropdown"
                toggle={<KebabToggle onToggle={onDropdownToggle} />}
                isOpen={dropdownVisibility}
                dropdownItems={dropdownItems}
                isPlain
                position="right"
                {...overrideDropdownProps}
                onSelect={onDropdownSelect}
              />
            </CardActions>
          )}
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
