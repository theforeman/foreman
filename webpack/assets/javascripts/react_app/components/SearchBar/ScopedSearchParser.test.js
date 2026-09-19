import {
  parseScopedSearchQuery,
  convertFiltersToQuery,
  updateFilterInQuery,
  removeFilterFromQuery,
  addFilterToQuery,
} from './ScopedSearchParser';

describe('ScopedSearchParser', () => {
  describe('parseScopedSearchQuery', () => {
    it('should parse a simple equality filter', () => {
      const result = parseScopedSearchQuery('name = test');
      expect(result).toEqual([{ field: 'name', operator: '=', value: 'test' }]);
    });

    it('should parse multiple filters with AND', () => {
      const result = parseScopedSearchQuery('name = test and status != pending');
      expect(result).toEqual([
        { field: 'name', operator: '=', value: 'test' },
        { field: 'status', operator: '!=', value: 'pending' },
      ]);
    });

    it('should parse filters with quoted values', () => {
      const result = parseScopedSearchQuery('name = "test value"');
      expect(result).toEqual([
        { field: 'name', operator: '=', value: 'test value' },
      ]);
    });

    it('should handle various operators', () => {
      const operators = ['=', '!=', '>', '<', '>=', '<=', '~', '!~', '^', '!^'];
      operators.forEach(op => {
        const result = parseScopedSearchQuery(`field ${op} value`);
        expect(result).toEqual([{ field: 'field', operator: op, value: 'value' }]);
      });
    });

    it('should handle empty query', () => {
      expect(parseScopedSearchQuery('')).toEqual([]);
      expect(parseScopedSearchQuery(null)).toEqual([]);
      expect(parseScopedSearchQuery(undefined)).toEqual([]);
    });

    it('should parse complex queries', () => {
      const result = parseScopedSearchQuery(
        'name ~ prod and status = active and count > 10'
      );
      expect(result).toEqual([
        { field: 'name', operator: '~', value: 'prod' },
        { field: 'status', operator: '=', value: 'active' },
        { field: 'count', operator: '>', value: '10' },
      ]);
    });

    it('should handle single quotes', () => {
      const result = parseScopedSearchQuery("name = 'test value'");
      expect(result).toEqual([
        { field: 'name', operator: '=', value: 'test value' },
      ]);
    });

    it('should handle mixed spacing', () => {
      const result = parseScopedSearchQuery('name=test and  status  !=  pending');
      expect(result).toEqual([
        { field: 'name', operator: '=', value: 'test' },
        { field: 'status', operator: '!=', value: 'pending' },
      ]);
    });

    it('should handle OR operator', () => {
      const result = parseScopedSearchQuery('name = test or name = prod');
      expect(result).toEqual([
        { field: 'name', operator: '=', value: 'test' },
        { field: 'name', operator: '=', value: 'prod' },
      ]);
    });

    it('should handle NOT operator', () => {
      const result = parseScopedSearchQuery('not name = test');
      expect(result).toEqual([{ field: 'name', operator: '=', value: 'test' }]);
    });

    it('should handle HAS operator', () => {
      const result = parseScopedSearchQuery('has name');
      expect(result).toEqual([]);
    });
  });

  describe('convertFiltersToQuery', () => {
    it('should convert simple filter to query', () => {
      const filters = [{ field: 'name', operator: '=', value: 'test' }];
      expect(convertFiltersToQuery(filters)).toBe('name = test');
    });

    it('should convert multiple filters to query with AND', () => {
      const filters = [
        { field: 'name', operator: '=', value: 'test' },
        { field: 'status', operator: '!=', value: 'pending' },
      ];
      expect(convertFiltersToQuery(filters)).toBe(
        'name = test and status != pending'
      );
    });

    it('should quote values with spaces', () => {
      const filters = [{ field: 'name', operator: '=', value: 'test value' }];
      expect(convertFiltersToQuery(filters)).toBe('name = "test value"');
    });

    it('should handle empty filters array', () => {
      expect(convertFiltersToQuery([])).toBe('');
      expect(convertFiltersToQuery(null)).toBe('');
      expect(convertFiltersToQuery(undefined)).toBe('');
    });

    it('should skip invalid filters', () => {
      const filters = [
        { field: 'name', operator: '=', value: 'test' },
        { field: '', operator: '=', value: 'test' },
        { field: 'status', operator: '', value: 'pending' },
      ];
      expect(convertFiltersToQuery(filters)).toBe('name = test');
    });

    it('should handle various operators', () => {
      const filters = [{ field: 'count', operator: '>=', value: '10' }];
      expect(convertFiltersToQuery(filters)).toBe('count >= 10');
    });

    it('should quote values with commas', () => {
      const filters = [{ field: 'tags', operator: '=', value: 'a,b,c' }];
      expect(convertFiltersToQuery(filters)).toBe('tags = "a,b,c"');
    });

    it('should quote values with parentheses', () => {
      const filters = [{ field: 'name', operator: '=', value: 'test(1)' }];
      expect(convertFiltersToQuery(filters)).toBe('name = "test(1)"');
    });
  });

  describe('updateFilterInQuery', () => {
    it('should update an existing filter', () => {
      const query = 'name = test and status = active';
      const oldFilter = { field: 'name', operator: '=', value: 'test' };
      const newFilter = { field: 'name', operator: '=', value: 'prod' };
      const result = updateFilterInQuery(query, oldFilter, newFilter);
      expect(result).toBe('name = prod and status = active');
    });

    it('should remove a filter when newFilter is null', () => {
      const query = 'name = test and status = active';
      const filterToRemove = { field: 'name', operator: '=', value: 'test' };
      const result = updateFilterInQuery(query, filterToRemove, null);
      expect(result).toBe('status = active');
    });

    it('should return original query if filter not found', () => {
      const query = 'name = test';
      const oldFilter = { field: 'status', operator: '=', value: 'active' };
      const newFilter = { field: 'status', operator: '=', value: 'pending' };
      const result = updateFilterInQuery(query, oldFilter, newFilter);
      expect(result).toBe('name = test');
    });
  });

  describe('removeFilterFromQuery', () => {
    it('should remove a filter from query', () => {
      const query = 'name = test and status = active and count > 5';
      const filterToRemove = { field: 'status', operator: '=', value: 'active' };
      const result = removeFilterFromQuery(query, filterToRemove);
      expect(result).toBe('name = test and count > 5');
    });

    it('should handle removing the only filter', () => {
      const query = 'name = test';
      const filterToRemove = { field: 'name', operator: '=', value: 'test' };
      const result = removeFilterFromQuery(query, filterToRemove);
      expect(result).toBe('');
    });
  });

  describe('addFilterToQuery', () => {
    it('should add a filter to existing query', () => {
      const query = 'name = test';
      const newFilter = { field: 'status', operator: '=', value: 'active' };
      const result = addFilterToQuery(query, newFilter);
      expect(result).toBe('name = test and status = active');
    });

    it('should add a filter to empty query', () => {
      const query = '';
      const newFilter = { field: 'name', operator: '=', value: 'test' };
      const result = addFilterToQuery(query, newFilter);
      expect(result).toBe('name = test');
    });
  });

  describe('round-trip conversion', () => {
    it('should maintain query integrity through parse and convert', () => {
      const originalQuery = 'name = test and status != pending and count >= 10';
      const filters = parseScopedSearchQuery(originalQuery);
      const reconstructedQuery = convertFiltersToQuery(filters);
      expect(reconstructedQuery).toBe(originalQuery);
    });

    it('should handle quoted values in round-trip', () => {
      const originalQuery = 'name = "test value" and status = active';
      const filters = parseScopedSearchQuery(originalQuery);
      const reconstructedQuery = convertFiltersToQuery(filters);
      expect(reconstructedQuery).toBe(originalQuery);
    });
  });
});
