import React from 'react';
import { storiesOf } from '@storybook/react';
import { date, boolean, select, withKnobs } from '@storybook/addon-knobs';
import IsoDate from './IsoDate';
import LongDateTime from './LongDateTime';
import RelativeDateTime from './RelativeDateTime';
import ShortDateTime from './ShortDateTime';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';
import Code from '../../../../../../stories/components/Code';

storiesOf('Components/Common', module)
  .addDecorator(withKnobs)
  .add('Dates', () => {
    const now = new Date();
    const defaultValue = new Date('2018-11-12 00:54:55 -1100');

    const dateToShow = new Date(date('Date and time in your time zone', defaultValue));
    const showSeconds = boolean('Show seconds');

    const timezoneOptions = [
      'America/Phoenix',
      'America/Chicago',
      'America/New_York',
      'UTC',
      'Europe/Prague',
      'Europe/Kiev',
      'Asia/Tel_Aviv',
    ];
    const timezone = select('User\'s time zone', timezoneOptions, timezoneOptions[1]);

    const DatesStorybook = i18nProviderWrapperFactory(now, timezone)(() => (
      <div className="storybook-body">
        <h1>Dates</h1>

        There are 4 date/time formats that should be used accross the Foreman and plugins.
        Each of the formats is represented by one React component.
        <br />
        <br />
        Examples display {dateToShow.toString()}.

        <h3>IsoDate</h3>
        Renders only date in iso format:
        <pre>
          <IsoDate date={dateToShow} defaultValue="N/A" />
        </pre>

        <h3>LongDateTime</h3>
        Renders full date with time, seconds can be displyed optionally:
        <pre>
          <LongDateTime date={dateToShow} defaultValue="N/A" seconds={showSeconds} />
        </pre>
        There's an erb helper alernative for rendering the same format:
        <Code lang="ruby">
          date_time_absolute(time, :short, seconds = false)
        </Code>

        <h3>ShortDateTime</h3>
        Renders shortened date with time, seconds can be displyed optionally:
        <pre>
          <ShortDateTime date={dateToShow} defaultValue="N/A" seconds={showSeconds} />
        </pre>
        There's an erb helper alernative for rendering the same format:
        <Code lang="ruby">
          date_time_absolute(time, :long, seconds = false)
        </Code>

        <h3>RelativeDateTime</h3>
        Renders relative date with long date in a tooltop:
        <pre>
          <RelativeDateTime date={dateToShow} defaultValue="N/A" />
        </pre>
        There's an erb helper alernative for rendering a relative time:
        <Code lang="ruby">
          date_time_relative(time)
        </Code>
      </div>
    ));

    return (<DatesStorybook />);
  });
