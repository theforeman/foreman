import { useState, useRef, useEffect, useCallback, useMemo } from 'react';
import { isEmpty } from 'lodash';
import { useLocation } from 'react-router-dom';

class ReactConnectedSet extends Set {
  constructor(initialValue, forceRender) {
    super();
    this.forceRender = forceRender;
    // The constructor would normally call add() with the initial value, but since we
    // must call super() at the top, this.forceRender() isn't defined yet.
    // So, we call super() above with no argument, then call add() manually below
    // after forceRender is defined
    if (initialValue) {
      if (initialValue.constructor.name === 'Array') {
        initialValue.forEach(id => super.add(id));
      } else {
        super.add(initialValue);
      }
    }
  }

  add(value) {
    const result = super.add(value); // ensuring these methods have the same API as the superclass
    this.forceRender();
    return result;
  }

  clear() {
    const result = super.clear();
    this.forceRender();
    return result;
  }

  delete(value) {
    const result = super.delete(value);
    this.forceRender();
    return result;
  }

  onToggle(isOpen, id) {
    if (isOpen) {
      this.add(id);
    } else {
      this.delete(id);
    }
  }

  addAll(ids) {
    ids.forEach(id => super.add(id));
    this.forceRender();
  }
}

export const useSet = initialArry => {
  const [, setToggle] = useState(Date.now());
  // needed because mutating a Ref won't cause React to rerender
  const forceRender = () => setToggle(Symbol('useSet'));
  const set = useRef(new ReactConnectedSet(initialArry, forceRender));
  return set.current;
};

export const useSelectionSet = ({
  results,
  metadata,
  defaultArry = [],
  initialArry = [],
  idColumn = 'id',
  isSelectable = () => true,
}) => {
  const selectionSet = useSet(initialArry);
  const pageIds = results?.map(result => result[idColumn]) ?? [];
  const selectableResults = useMemo(
    () => results?.filter(result => isSelectable(result)) ?? [],
    [results, isSelectable]
  );
  const selectedResults = useRef({}); // { id: result }
  const canSelect = useCallback(
    id => {
      const selectableIds = new Set(
        selectableResults.map(result => result[idColumn])
      );
      return selectableIds.has(id);
    },
    [idColumn, selectableResults]
  );
  const areAllRowsOnPageSelected = () =>
    Number(pageIds?.length) > 0 &&
    pageIds.every(result => selectionSet.has(result) || !canSelect(result));

  const areAllRowsSelected = () =>
    Number(selectionSet.size) > 0 &&
    selectionSet.size === Number(metadata.selectable);

  const selectPage = () => {
    const selectablePageIds = pageIds.filter(canSelect);
    selectionSet.addAll(selectablePageIds);
    selectableResults.forEach(result => {
      selectedResults.current[result[idColumn]] = result;
    });
  };

  const clearSelectedResults = () => {
    selectedResults.current = {};
  };

  const selectNone = () => {
    selectionSet.clear();
    clearSelectedResults();
  };
  const selectOne = (isSelected, id, data) => {
    if (canSelect(id)) {
      if (isSelected) {
        if (data) selectedResults.current[id] = data;
        selectionSet.add(id);
      } else {
        delete selectedResults.current[id];
        selectionSet.delete(id);
      }
    }
  };
  const selectDefault = () => {
    selectNone();
    selectionSet.addAll(defaultArry);
    defaultArry.forEach(id => {
      selectedResults.current[id] = results.find(
        result => result[idColumn] === id
      );
    });
  };

  const selectedCount = selectionSet.size;

  const isSelected = useCallback(id => canSelect(id) && selectionSet.has(id), [
    canSelect,
    selectionSet,
  ]);

  return {
    selectOne,
    selectedCount,
    areAllRowsOnPageSelected,
    areAllRowsSelected,
    selectPage,
    selectNone,
    selectDefault,
    isSelected,
    isSelectable: canSelect,
    selectionSet,
    selectedResults: Object.values(selectedResults.current),
    clearSelectedResults,
  };
};

const usePrevious = value => {
  const ref = useRef();
  useEffect(() => {
    ref.current = value;
  });
  return ref.current;
};

export const useBulkSelect = ({
  results,
  metadata,
  initialArry = [],
  initialExclusionArry = [],
  defaultArry = [],
  initialSearchQuery = '',
  idColumn = 'id',
  filtersQuery = '',
  isSelectable,
  initialSelectAllMode = false,
}) => {
  const { selectionSet: inclusionSet, ...selectOptions } = useSelectionSet({
    results,
    metadata,
    initialArry,
    defaultArry,
    idColumn,
    isSelectable,
  });
  const exclusionSet = useSet(initialExclusionArry);
  const [searchQuery, updateSearchQuery] = useState(initialSearchQuery);
  const [selectAllMode, setSelectAllMode] = useState(initialSelectAllMode);
  const selectedCount = selectAllMode
    ? Number(metadata.selectable || metadata.total) - exclusionSet.size
    : selectOptions.selectedCount;

  const areAllRowsOnPageSelected = () =>
    selectAllMode || selectOptions.areAllRowsOnPageSelected();

  const areAllRowsSelected = () =>
    (selectAllMode && exclusionSet.size === 0) ||
    selectOptions.areAllRowsSelected();

  const isSelected = useCallback(
    id => {
      if (!selectOptions.isSelectable(id)) {
        return false;
      }
      if (selectAllMode) {
        return !exclusionSet.has(id);
      }
      return inclusionSet.has(id);
    },
    [exclusionSet, inclusionSet, selectAllMode, selectOptions]
  );

  const selectPage = () => {
    setSelectAllMode(false);
    selectOptions.selectPage();
  };

  const selectNone = useCallback(() => {
    setSelectAllMode(false);
    exclusionSet.clear();
    inclusionSet.clear();
    selectOptions.clearSelectedResults();
  }, [exclusionSet, inclusionSet, selectOptions]);

  const selectOne = (isRowSelected, id, data) => {
    if (selectAllMode) {
      if (isRowSelected) {
        exclusionSet.delete(id);
      } else {
        exclusionSet.add(id);
      }
    } else {
      selectOptions.selectOne(isRowSelected, id, data);
    }
  };

  const selectAll = checked => {
    setSelectAllMode(checked);
    if (checked) {
      exclusionSet.clear();
    } else {
      inclusionSet.clear();
    }
  };

  const selectDefault = () => {
    selectNone();
    selectOptions.selectDefault();
  };

  const fetchBulkParams = ({
    idColumnName = idColumn,
    selectAllQuery = '',
  } = {}) => {
    const searchQueryWithExclusionSet = () => {
      const query = [
        searchQuery,
        filtersQuery,
        !isEmpty(exclusionSet) &&
          `${idColumnName} !^ (${[...exclusionSet].join(',')})`,
        selectAllQuery,
      ];
      return query.filter(item => item).join(' and ');
    };

    const searchQueryWithInclusionSet = () => {
      if (isEmpty(inclusionSet))
        throw new Error('Cannot build a search query with no items selected');
      return `${idColumnName} ^ (${[...inclusionSet].join(',')})`;
    };
    return selectAllMode
      ? searchQueryWithExclusionSet()
      : searchQueryWithInclusionSet();
  };

  const prevSearchRef = usePrevious({ searchQuery });

  useEffect(() => {
    // if search value changed and cleared from a string to empty value
    // And it was select all -> then reset selections
    if (
      prevSearchRef &&
      !isEmpty(prevSearchRef.searchQuery) &&
      isEmpty(searchQuery) &&
      selectAllMode
    ) {
      selectNone();
    }
  }, [searchQuery, selectAllMode, prevSearchRef, selectNone]);

  return {
    ...selectOptions,
    selectPage,
    selectNone,
    selectAll,
    selectDefault,
    selectAllMode,
    isSelected,
    selectedCount,
    fetchBulkParams,
    searchQuery,
    updateSearchQuery,
    selectOne,
    areAllRowsOnPageSelected,
    areAllRowsSelected,
    inclusionSet,
    exclusionSet,
  };
};

export const friendlySearchParam = searchParam =>
  decodeURIComponent(searchParam.replace(/\+/g, ' '));

// takes a url query like ?type=security&search=name+~+foo
// and returns an object
// {
//   type: 'security',
//   searchParam: 'name ~ foo'
// }
export const useUrlParams = () => {
  const location = useLocation();
  const { search: urlSearchParam, ...urlParams } = Object.fromEntries(
    new URLSearchParams(location.search).entries()
  );
  const searchParam = urlSearchParam ? friendlySearchParam(urlSearchParam) : '';

  return {
    searchParam,
    ...urlParams,
  };
};
