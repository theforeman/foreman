import { flattenPingResults, computeOverallStatus } from '../helpers';

describe('flattenPingResults', () => {
  it('handles various data structures correctly', () => {
    // Simple nested structure
    const simpleInput = {
      foreman: {
        database: { active: true, duration_ms: '0' }
      }
    };
    const simpleResult = flattenPingResults(simpleInput);
    expect(simpleResult).toEqual([{
      serviceNameParts: ['foreman', 'database'],
      data: { active: true, duration_ms: '0' }
    }]);

    // Array structures
    const arrayInput = {
      foreman: {
        cache: {
          servers: [
            { status: 'ok', duration_ms: '1' },
            { status: 'fail', duration_ms: '5' }
          ]
        }
      }
    };
    const arrayResult = flattenPingResults(arrayInput);
    expect(arrayResult).toHaveLength(2);
    expect(arrayResult[0].serviceNameParts).toEqual(['foreman', 'cache', 'servers']);

    // Nested services structure (skips 'services' key)
    const nestedInput = {
      foreman_rh_cloud: {
        services: {
          advisor: { status: 'FAIL', message: '502 Bad Gateway' },
          vulnerability: { status: 'ok', duration_ms: '25' }
        },
        status: 'FAIL'
      }
    };
    const nestedResult = flattenPingResults(nestedInput);
    expect(nestedResult).toHaveLength(2);
    expect(nestedResult[0].serviceNameParts).toEqual(['foreman_rh_cloud', 'advisor']);
  });

  it('handles edge cases', () => {
    expect(flattenPingResults({})).toEqual([]);
    expect(flattenPingResults({ simple: 'value', number: 42 })).toEqual([]);
    expect(() => flattenPingResults(null)).toThrow();
  });
});

describe('computeOverallStatus', () => {
  it('returns correct status based on service health', () => {
    // All OK
    const okServices = [
      { serviceNameParts: ['db'], data: { active: true } },
      { serviceNameParts: ['cache'], data: { status: 'ok' } }
    ];
    expect(computeOverallStatus(okServices)).toBe('OK');

    // Has failures
    const failServices = [
      { serviceNameParts: ['db'], data: { active: true } },
      { serviceNameParts: ['api'], data: { status: 'FAIL' } }
    ];
    expect(computeOverallStatus(failServices)).toBe('FAIL');

    // Case insensitive
    const mixedCaseServices = [
      { serviceNameParts: ['service'], data: { active: 'False' } }
    ];
    expect(computeOverallStatus(mixedCaseServices)).toBe('FAIL');

    // Edge cases
    expect(computeOverallStatus([])).toBe('Unknown');
    expect(computeOverallStatus(null)).toBe('Unknown');
    expect(computeOverallStatus([{ serviceNameParts: ['test'], data: { duration_ms: '10' } }])).toBe('OK');
  });
});
