import URI from 'urijs';
import { foremanUrl } from '../../../../foreman_tools';

export const docUrl = (foremanVersion) => {
  const rootUrl = `https://docs.theforeman.org/${foremanVersion}/`
  const section = 'Managing_Hosts/index-foreman-el.html#registering-a-host_managing-hosts'

  const url = new URI({path: '/links/manual', query: { root_url: rootUrl, section: section }});
  return foremanUrl(url.href());
}
