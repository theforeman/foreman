/* eslint-disable no-console */
import { getLCP, getFID, getCLS } from 'web-vitals';

/**
 * More about web vitals metrics can be found here: https://web.dev/vitals/
 */
const reportWebVitals = () => {
  const slowLoadingWarning = ({ value }) =>
    value > 2500 &&
    console.warn(
      `LCP is ${value}. To provide a good user experience, LCP should occur within 2.5 seconds of when the page first starts loading.`
    );
  const lowInteractivityWarning = ({ value }) =>
    value > 100 &&
    console.warn(
      `FID is ${value}. To provide a good user experience, pages should have a FID of 100 milliseconds or less.`
    );
  const badVisualStabilityWarning = ({ value }) =>
    value > 0.1 &&
    console.warn(
      `CLS is ${value}. To provide a good user experience, pages should maintain a CLS of 0.1. or less.`
    );

  getLCP(slowLoadingWarning, true);
  getFID(lowInteractivityWarning, true);
  getCLS(badVisualStabilityWarning, true);
};

export default reportWebVitals;
