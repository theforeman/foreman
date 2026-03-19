import React from 'react';
import {
  Form,
  Skeleton,
  Stack,
  StackItem,
  Flex,
  FlexItem,
} from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';

const labelSkeleton = <Skeleton height="14px" width="30%" />;

const ModelFormSkeleton = () => (
  <Form isWidthLimited id="model-form-skeleton">
    <Stack hasGutter>
      <StackItem>
        {labelSkeleton}
        <Skeleton height="36px" screenreaderText={__('Loading form')} />
      </StackItem>
      <StackItem>
        {labelSkeleton}
        <Skeleton height="36px" />
      </StackItem>
      <StackItem>
        {labelSkeleton}
        <Skeleton height="36px" />
      </StackItem>
      <StackItem>
        {labelSkeleton}
        <Skeleton height="36px" />
      </StackItem>
      <StackItem>
        {labelSkeleton}
        <Skeleton height="140px" />
      </StackItem>
      <StackItem>
        <Flex gap={{ default: 'gapMd' }}>
          <FlexItem>
            <Skeleton height="36px" width="80px" />
          </FlexItem>
          <FlexItem>
            <Skeleton height="36px" width="72px" />
          </FlexItem>
        </Flex>
      </StackItem>
    </Stack>
  </Form>
);

export default ModelFormSkeleton;
