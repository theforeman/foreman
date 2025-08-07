/**
 * Recursively traverses a nested object of service statuses and flattens it
 * into an array of service objects suitable for rendering.
 *
 * @param {object} obj - The current object node in the data structure to process.
 * @param {string[]} prefix - An array of parent keys, representing the path to the current node.
 * @returns {Array<{serviceNameParts: string[], data: object}>} A flat array of service statuses.
 * Each service has its name as an array of parts and its associated data payload.
 *
 * Example obj: {"foreman":{"database":{"active":true,"duration_ms":"0"},"cache":
 * {"servers":[{"status":"ok","duration_ms":"1"}]}},"foreman_rh_cloud":{"services":{"advisor":
 * {"status":"FAIL","message":"502 Bad Gateway"},"vulnerability":{"status":"ok","duration_ms":"25"}},
 * "status":"FAIL"}
 */
export const flattenPingResults = (obj, prefix = []) => {
  let results = [];

  // BASE CASE
  if (Object.hasOwn(obj, 'status') || Object.hasOwn(obj, 'active')) {
    // EDGE CASE: Some parent objects have an overall 'status' key
    // but also contain a nested 'services' object
    if (Object.hasOwn(obj, 'services') && typeof obj.services === 'object') {
      // This is a parent object, so we'll continue to the recursive step below
    } else {
      results.push({
        serviceNameParts: prefix,
        data: obj,
      });
      return results;
    }
  }

  // RECURSIVE STEP
  // eslint-disable-next-line no-unused-vars
  for (const [key, value] of Object.entries(obj)) {
    // We only recurse if the value is a non-null object (which includes arrays).
    if (value && typeof value === 'object') {
      // If the object we are currently iterating over is an array, we don't add
      // its numeric index to the service name path.
      // Also, don't add 'services'
      const newPrefix =
        key === 'services' || Array.isArray(obj) ? prefix : [...prefix, key];
      results = results.concat(flattenPingResults(value, newPrefix));
    }
  }
  return results;
};

export const computeOverallStatus = serviceStatuses => {
  if (!serviceStatuses || serviceStatuses.length === 0) {
    return 'Unknown';
  }

  const hasFailure = serviceStatuses.some(({ data }) => {
    const dataStatus = String(data.status || '').toLowerCase();
    const dataActive = String(data.active || '').toLowerCase();

    // either of these will cause the .some above to fail
    return dataStatus === 'fail' || dataActive === 'false';
  });

  return hasFailure ? 'FAIL' : 'OK';
};
