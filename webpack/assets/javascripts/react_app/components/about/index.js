import React from 'react';
import TabsWrapper from '../common/tabs';
import AboutComputeTable from './compute';
import AboutPluginTable from './plugin';
import AboutProviderTable from './provider';
import AboutProxyTable from './proxies';

const About = ({ data }) => {
  const {
    compute, proxy, provider, plugin,
  } = data;
  const tabs = [
    __('Smart Proxies'),
    __('Available Providers'),
    __('Compute Resources'),
    __('Plugins'),
  ];

  return (
    <TabsWrapper id="about_tabs" tabs={tabs}>
      <AboutProxyTable data={proxy} />
      <AboutProviderTable data={provider} />
      <AboutComputeTable data={compute} />
      <AboutPluginTable data={plugin} />
    </TabsWrapper>
  );
};

export default About;
