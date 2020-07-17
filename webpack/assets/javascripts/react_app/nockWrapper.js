import nock from 'nock';

// Using the library 'nock' as it matches actual network requests rather than mock another
// library. This is helpful when the request is not coming from Katello. For example, axios
// called within Katello can be mocked with axios-mock-adapter or similar, but a http request
// made by axios that is coming from Foreman cannot be mocked by axios-mock-adapter or a
// jest mock within Katello. So to do this, we can mock the request a level deeper within
// nodejs by using nock.
export const nockInstance = nock('http://localhost');

// Calling .done() with nock asserts that the request was fufilled. We use a timeout to ensure
// that the component has set up and made the request before the assertion is made. This function
// polls until the nock scope is met. If the `done` callback from jest is passed in, it will
// call it once the request is made, telling jest the test is done. This is to make sure all
// nock expectations are met and cleared before moving on to the next test.
export const assertNockRequest = (nockScope, jestDone, tries = 10) => {
  const interval = 500;
  let i = 0;
  const poll = setInterval(() => {
    i += 1;
    if (i === tries) {
      /* eslint-disable-next-line no-console */
      console.error(
        `Nock stubbed call ${nockScope.pendingMocks()} was not met in time!`
      );
    }
    if (nockScope.isDone()) {
      nockScope.done(); // Assert nock request
      if (jestDone) jestDone(); // Tell jest test is done
      clearInterval(poll); // Clear the interval so polling stops
    }
  }, interval);
};

export const mockAutocomplete = (
  instance,
  autoCompUrl,
  query = true,
  response = [],
  times = 1
) =>
  instance
    .get(autoCompUrl)
    .times(times)
    .query(query) // can pass in function, see nock docs
    .reply(200, response);

export const mockSetting = (instance, name, value) =>
  instance
    .get(`/api/v2/settings/${name}`)
    .query(true) // can pass in function, see nock docs
    .reply(200, { name, value });

export default nock;
