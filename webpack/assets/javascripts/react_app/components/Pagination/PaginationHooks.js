import { getURIperPage } from '../../common/urlHelpers';
import { useForemanSettings } from '../../Root/Context/ForemanContext';

export const usePaginationOptions = (isPF3 = false) => {
  const perPageOptions = new Set([5, 10, 15, 25, 50]);
  const { perPage } = useForemanSettings();
  const URIPerPage = getURIperPage();

  perPageOptions.add(perPage);
  if (URIPerPage) perPageOptions.add(URIPerPage);
  const options = [...perPageOptions].sort((a, b) => a - b);
  if (isPF3) return options;
  return options.map(value => ({ title: value.toString(), value }));
};
