/* eslint-disable promise/prefer-await-to-then */
// Configure Enzyme
import { mount } from '@theforeman/test';
import React from 'react';
import LongDateTime from './LongDateTime';
import { i18nProviderWrapperFactory } from '../../../common/i18nProviderWrapperFactory';
import { intl } from '../../../common/I18n';

describe('LongDateTime', () => {
  const date = new Date('2017-10-13 00:54:55 -1100');
  const now = new Date('2017-10-28 00:00:00 -1100');
  const IntlDate = i18nProviderWrapperFactory(now, 'UTC')(LongDateTime);

  it('formats date', () => {
    const wrapper = mount(
      <IntlDate date={date} defaultValue="Default value" />
    );

    intl.ready.then(() => {
      wrapper.update();
      if (process.version.startsWith('v14') || process.version.startsWith('v16')) {
        expect(wrapper.find('LongDateTime')).toMatchInlineSnapshot(
          `
          <LongDateTime
            date={2017-10-13T11:54:55.000Z}
            defaultValue="Default value"
            seconds={false}
            showRelativeTimeTooltip={false}
          >
            <span>
              <FormattedDate
                day="2-digit"
                hour="2-digit"
                minute="2-digit"
                month="long"
                value={2017-10-13T11:54:55.000Z}
                year="numeric"
              >
                <span>
                  October 13, 2017, 11:54 AM
                </span>
              </FormattedDate>
            </span>
          </LongDateTime>
        `
        );
      } else {
        expect(wrapper.find('LongDateTime')).toMatchInlineSnapshot(
          `
          <LongDateTime
            date={2017-10-13T11:54:55.000Z}
            defaultValue="Default value"
            seconds={false}
            showRelativeTimeTooltip={false}
          >
            <span>
              <FormattedDate
                day="2-digit"
                hour="2-digit"
                minute="2-digit"
                month="long"
                value={2017-10-13T11:54:55.000Z}
                year="numeric"
              >
                <span>
                  October 13, 2017 at 11:54 AM
                </span>
              </FormattedDate>
            </span>
          </LongDateTime>
        `
        );
      }
    });
  });

  it('formats date with relative tooltip', () => {
    const wrapper = mount(
      <IntlDate
        date={date}
        defaultValue="Default value"
        showRelativeTimeTooltip
      />
    );

    intl.ready.then(() => {
      wrapper.update();
      if (process.version.startsWith('v14') || process.version.startsWith('v16')) {
        expect(wrapper.find('LongDateTime')).toMatchInlineSnapshot(
          `
          <LongDateTime
            date={2017-10-13T11:54:55.000Z}
            defaultValue="Default value"
            seconds={false}
            showRelativeTimeTooltip={true}
          >
            <span
              title="15 days ago"
            >
              <FormattedDate
                day="2-digit"
                hour="2-digit"
                minute="2-digit"
                month="long"
                value={2017-10-13T11:54:55.000Z}
                year="numeric"
              >
                <span>
                  October 13, 2017, 11:54 AM
                </span>
              </FormattedDate>
            </span>
          </LongDateTime>
        `
        );
      } else {
        expect(wrapper.find('LongDateTime')).toMatchInlineSnapshot(
          `
          <LongDateTime
            date={2017-10-13T11:54:55.000Z}
            defaultValue="Default value"
            seconds={false}
            showRelativeTimeTooltip={true}
          >
            <span
              title="15 days ago"
            >
              <FormattedDate
                day="2-digit"
                hour="2-digit"
                minute="2-digit"
                month="long"
                value={2017-10-13T11:54:55.000Z}
                year="numeric"
              >
                <span>
                  October 13, 2017 at 11:54 AM
                </span>
              </FormattedDate>
            </span>
          </LongDateTime>
        `
        );
      }
    });
  });

  it('formats date with seconds', () => {
    const wrapper = mount(
      <IntlDate date={date} seconds defaultValue="Default value" />
    );

    intl.ready.then(() => {
      wrapper.update();
      if (process.version.startsWith('v14') || process.version.startsWith('v16')) {
        expect(wrapper.find('LongDateTime')).toMatchInlineSnapshot(
          `
          <LongDateTime
            date={2017-10-13T11:54:55.000Z}
            defaultValue="Default value"
            seconds={true}
            showRelativeTimeTooltip={false}
          >
            <span>
              <FormattedDate
                day="2-digit"
                hour="2-digit"
                minute="2-digit"
                month="long"
                second="2-digit"
                value={2017-10-13T11:54:55.000Z}
                year="numeric"
              >
                <span>
                  October 13, 2017, 11:54:55 AM
                </span>
              </FormattedDate>
            </span>
          </LongDateTime>
        `
        );
      } else {
        expect(wrapper.find('LongDateTime')).toMatchInlineSnapshot(
          `
          <LongDateTime
            date={2017-10-13T11:54:55.000Z}
            defaultValue="Default value"
            seconds={true}
            showRelativeTimeTooltip={false}
          >
            <span>
              <FormattedDate
                day="2-digit"
                hour="2-digit"
                minute="2-digit"
                month="long"
                second="2-digit"
                value={2017-10-13T11:54:55.000Z}
                year="numeric"
              >
                <span>
                  October 13, 2017 at 11:54:55 AM
                </span>
              </FormattedDate>
            </span>
          </LongDateTime>
        `
        );
      }
    });
  });

  it('renders default value', () => {
    const wrapper = mount(
      <IntlDate date={null} defaultValue="Default value" />
    );

    intl.ready.then(() => {
      wrapper.update();
      expect(wrapper.find('LongDateTime')).toMatchInlineSnapshot(`
        <LongDateTime
          date={null}
          defaultValue="Default value"
          seconds={false}
          showRelativeTimeTooltip={false}
        >
          <span>
            Default value
          </span>
        </LongDateTime>
      `);
    });
  });
});
