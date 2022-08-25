import PropTypes from 'prop-types';
import React, { useState } from 'react';
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

import { useLocalStorage } from '../../../../../common/hooks/Storage';
import { useDidUpdateEffect } from '../../../../../common/hooks/Common';

const CardTemplate = ({
  header,
  children,
  expandable,
  isExpandedGlobal,
  dropdownItems,
  overrideGridProps,
  overrideDropdownProps,
  masonryLayout,
}) => {
  const [dropdownVisibility, setDropdownVisibility] = useState(false);
  const [isExpanded, setExpanded] = useLocalStorage(
    `${header} card expanded`,
    true
  );
  const onDropdownToggle = isOpen => setDropdownVisibility(isOpen);
  const onExpandCallback = () => setExpanded(prevState => !prevState);
  const onDropdownSelect = event => {
    setDropdownVisibility(prevState => !prevState);
    // https://github.com/eslint/eslint/issues/12822
    // eslint-disable-next-line no-unused-expressions
    overrideDropdownProps?.onSelect?.(event);
  };
  useDidUpdateEffect(
    () => isExpandedGlobal !== undefined && setExpanded(isExpandedGlobal),
    [isExpandedGlobal]
  );
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
  isExpandedGlobal: PropTypes.bool,
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
  isExpandedGlobal: false,
  masonryLayout: false,
};

export default CardTemplate;
