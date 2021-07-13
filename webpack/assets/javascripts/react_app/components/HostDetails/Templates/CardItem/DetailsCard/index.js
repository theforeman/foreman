import PropTypes from 'prop-types';
import React from 'react';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
} from '@patternfly/react-core';
import CardItem from '../CardTemplate';
import SkeletonLoader from '../../../../common/SkeletonLoader';

const DetailsCardTemplate = ({
  children,
  title,
  status,
  overrideGridProps,
  ...props
}) => (
  <CardItem overrideGridProps={overrideGridProps} header={title}>
    <DescriptionList isAutoColumnWidths {...props}>
      {children.map(({ name, description }) => (
        <DescriptionListGroup key={name}>
          <DescriptionListTerm>{name}</DescriptionListTerm>
          <DescriptionListDescription>
            <SkeletonLoader status={status}>{description}</SkeletonLoader>
          </DescriptionListDescription>
        </DescriptionListGroup>
      ))}
    </DescriptionList>
  </CardItem>
);

DetailsCardTemplate.propTypes = {
  overrideGridProps: PropTypes.object,
  title: PropTypes.string.isRequired,
  status: PropTypes.string.isRequired,
  children: PropTypes.arrayOf(
    PropTypes.shape({ name: PropTypes.string, description: PropTypes.string })
  ).isRequired,
};

DetailsCardTemplate.defaultProps = {
  overrideGridProps: {},
};

export default DetailsCardTemplate;
