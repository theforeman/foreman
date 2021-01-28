import React from 'react';
import PowerStatus from './index';
import {
  Story,
  Code,
  Text,
  StoryWithCustomState,
} from '../../../../../../stories/components';
import {
  pendingStore,
  resolvedStore,
  resolvedStoreWithOff,
  errorStore,
  serverProps,
} from './PowerStatus.fixtures';

export default {
  title: 'Components/Power Status',
};

export const loading = () => (
  <StoryWithCustomState state={pendingStore}>
    <PowerStatus {...serverProps} />
  </StoryWithCustomState>
);

export const ON = () => (
  <StoryWithCustomState state={resolvedStore}>
    <PowerStatus {...serverProps} />
  </StoryWithCustomState>
);

export const OFF = () => (
  <StoryWithCustomState state={resolvedStoreWithOff}>
    <PowerStatus {...serverProps} />
  </StoryWithCustomState>
);

export const errorStory = () => (
  <StoryWithCustomState state={errorStore}>
    <PowerStatus {...serverProps} />
  </StoryWithCustomState>
);

errorStory.story = {
  name: 'Error',
};

export const connectedMD = () => (
  <Story>
    <Text>
      <h1>Using the connected component</h1>
      <br />
      <p>
        Currently the redux-connected component receives the following props:
      </p>
      <Code lang="javascript">{'{ id, url }'}</Code>
      <p>
        On the connected component mount we are making an API call with the
        given url,
      </p>
      <p>
        the state will update by it and the PowerStatus component will receive
        the following props from the selectors:
      </p>
      <Code lang="javascript">{'{ state, title }'}</Code>
    </Text>
  </Story>
);

connectedMD.story = {
  name: 'Using the redux-connected component',
};
