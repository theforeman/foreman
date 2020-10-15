import React from 'react';
import { date, boolean, select, withKnobs } from '@theforeman/stories';

import IsoDate from './IsoDate';
import LongDateTime from './LongDateTime';
import RelativeDateTime from './RelativeDateTime';
import ShortDateTime from './ShortDateTime';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';
import Code from '../../../../../../stories/components/Code';
import Story from '../../../../../../stories/components/Story';
import Text from '../../../../../../stories/components/Text';

export default {
  title: 'Components|Common',
  decorators: [withKnobs],
};

export const dates = () => {
  const now = new Date();
  const defaultValue = new Date('2018-11-12T00:54:55-1100');

  const dateToShow = new Date(
    date('Date and time in your time zone', defaultValue)
  );
  const showSeconds = boolean('Show seconds');
  const showRelativeTimeTooltip = boolean('Show relative time');

  const timezoneOptions = [
    'America/Phoenix',
    'America/Chicago',
    'America/New_York',
    'UTC',
    'Europe/Prague',
    'Europe/Kiev',
    'Asia/Jerusalem',
  ];
  const timezone = select(
    "User's time zone",
    timezoneOptions,
    timezoneOptions[1]
  );

  const DatesStorybook = i18nProviderWrapperFactory(
    now,
    timezone
  )(() => (
    <Story>
      <Text>
        <h1>Dates</h1>
        There are 4 date/time formats that should be used across the Foreman and
        plugins. Each of the formats is represented by one React component.
        <br />
        <br />
        Examples display {dateToShow.toString()}.<h3>IsoDate</h3>
        Renders only date in iso format:
        <pre>
          <IsoDate date={dateToShow} defaultValue="N/A" />
        </pre>
        <h3>LongDateTime</h3>
        Renders full date with time. Relative time tooltip and seconds can be
        displayed optionally :
        <pre>
          <LongDateTime
            date={dateToShow}
            defaultValue="N/A"
            seconds={showSeconds}
            showRelativeTimeTooltip={showRelativeTimeTooltip}
          />
        </pre>
        There&apos;s an erb helper alternative for rendering the same format
        with relative time tooltip true as a default:
        <Code lang="ruby">
          date_time_absolute(time, :short, seconds = false,
          show_relative_time_tooltip = true)
        </Code>
        <h3>ShortDateTime</h3>
        Renders shortened date with time. Relative time tooltip and seconds can
        be displayed optionally :
        <pre>
          <ShortDateTime
            date={dateToShow}
            defaultValue="N/A"
            seconds={showSeconds}
            showRelativeTimeTooltip={showRelativeTimeTooltip}
          />
        </pre>
        There&apos;s an erb helper alternative for rendering the same format
        with relative time tooltip true as a default:
        <Code lang="ruby">
          date_time_absolute(time, :long, seconds = false,
          show_relative_time_tooltip = true)
        </Code>
        <h3>RelativeDateTime</h3>
        Renders relative date with long date in a tooltip:
        <pre>
          <RelativeDateTime date={dateToShow} defaultValue="N/A" />
        </pre>
        There&apos;s an erb helper alternative for rendering a relative time:
        <Code lang="ruby">date_time_relative(time)</Code>
      </Text>
    </Story>
  ));

  return <DatesStorybook />;
};
