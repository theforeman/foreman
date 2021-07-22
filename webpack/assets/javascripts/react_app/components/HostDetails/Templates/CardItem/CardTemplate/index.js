import PropTypes from 'prop-types';
import React, { useState } from 'react';
import {
  Card,
  CardActions,
  CardHeader,
  Dropdown,
  KebabToggle,
  CardTitle,
  CardBody,
  GridItem,
} from '@patternfly/react-core';

const CardItem = ({
  header,
  children,
  dropdownItems,
  overrideGridProps,
  overrideDropdownProps,
}) => {
  const [dropdownVisibility, setDropdownVisibility] = useState(false);
  const onDropdownToggle = isOpen => setDropdownVisibility(isOpen);

  const onDropdownSelect = event => {
    setDropdownVisibility(prevState => !prevState);
    // https://github.com/eslint/eslint/issues/12822
    // eslint-disable-next-line no-unused-expressions
    overrideDropdownProps?.onSelect?.(event);
  };
  return (
    <GridItem xl2={3} md={6} lg={5} {...overrideGridProps}>
      <Card isHoverable>
        <CardHeader>
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
        <CardBody>{children}</CardBody>
      </Card>
    </GridItem>
  );
};

CardItem.propTypes = {
  header: PropTypes.node.isRequired,
  children: PropTypes.node,
  overrideGridProps: PropTypes.object,
  dropdownItems: PropTypes.arrayOf(PropTypes.node),
  overrideDropdownProps: PropTypes.object,
};

CardItem.defaultProps = {
  children: undefined,
  overrideGridProps: undefined,
  dropdownItems: undefined,
  overrideDropdownProps: {},
};

export default CardItem;
