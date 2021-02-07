import React from 'react';
import { ExclamationCircleIcon } from '@patternfly/react-icons';
import { STATUS } from '../../../constants';
import Story from '../../../../../../stories/components/Story';
import SkeletonLoader from '.';

export default {
  title: 'Components/Common/SkeletonLoader',
};

export const defaultStory = () => (
  <Story>
    <ul>
      <span>Loading:</span>
      <br />
      <SkeletonLoader status={STATUS.PENDING}>Content</SkeletonLoader>
    </ul>
    <ul>
      <span>Loading with multiple lines:</span>
      <br />
      <SkeletonLoader
        skeletonProps={{ count: 3 }}
        status={STATUS.PENDING}
      >
        Content
      </SkeletonLoader>
    </ul>
    <ul>
      <span>Resolved:</span>
      <br />
      <SkeletonLoader status={STATUS.RESOLVED}>Some Content</SkeletonLoader>
    </ul>
    <ul>
      <span>Error:</span>
      <br />
      <SkeletonLoader
        status={STATUS.ERROR}
        errorNode={
          <span style={{ color: '#C9190B' }}>
            <ExclamationCircleIcon /> Error
          </span>
        }
      />
    </ul>
    <ul>
      <span>Empty Value</span>
      <br />
      <SkeletonLoader status={STATUS.RESOLVED} />
    </ul>
  </Story>
);

defaultStory.story = {
  name: 'Skeleton Loader',
};
