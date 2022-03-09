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
} from '@patternfly/react-core';

import { useLocalStorage } from '../../../../../common/hooks/Storage';
import { useDidMountEffect } from '../../../../../common/hooks/Common';

const CardTemplate = ({
  header,
  children,
  expandable,
  isExpandedGlobal,
  dropdownItems,
  overrideGridProps,
  overrideDropdownProps,
}) => {
  const [dropdownVisibility, setDropdownVisibility] = useState(false);
  const [isExpanded, setExpanded] = useLocalStorage(header, true);
  const onDropdownToggle = isOpen => setDropdownVisibility(isOpen);
  const onExpandCallback = () => setExpanded(prevState => !prevState);
  const onDropdownSelect = event => {
    setDropdownVisibility(prevState => !prevState);
    // https://github.com/eslint/eslint/issues/12822
    // eslint-disable-next-line no-unused-expressions
    overrideDropdownProps?.onSelect?.(event);
  };
  useDidMountEffect(
    () => isExpandedGlobal !== undefined && setExpanded(isExpandedGlobal),
    [isExpandedGlobal]
  );

  return (
    <GridItem xl2={3} xl={4} md={6} lg={4} {...overrideGridProps}>
      <Card isExpanded={isExpanded} isSelectable>
        <CardHeader onExpand={expandable && onExpandCallback}>
          {dropdownItems && (
            <CardActions>
              <Dropdown
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
    </GridItem>
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
};

CardTemplate.defaultProps = {
  children: undefined,
  overrideGridProps: undefined,
  dropdownItems: undefined,
  overrideDropdownProps: {},
  expandable: false,
  isExpandedGlobal: false,
};

export default CardTemplate;
