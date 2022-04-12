import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import {
  Form,
  FormGroup,
  Checkbox,
  Alert,
  Popover,
  ActionGroup,
  Button,
} from '@patternfly/react-core';
import { HelpIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../common/I18n';
import SearchBar from '../../components/SearchBar';
import {
  setAutocompleteSearchQuery,
  updateDisability,
  updateController,
} from '../../components/AutoComplete/AutoCompleteActions';
import './FilterForm.scss';
import { SelectPermissions } from './SelectPermissions';
import { SelectResourceType } from './SelectResourceType';
import { SelectRole } from './SelectRole';
import { EMPTY_RESOURCE_TYPE, SEARCH_ID } from './FiltersFormConstants';
import { Taxonomies } from './Taxonomies';
import { APIActions } from '../../redux/API';
import { selectAutocompleteSearchQuery } from '../../components/AutoComplete/AutoCompleteSelectors';

export const FiltersForm = ({ roleName, roleId, isNew, data, history }) => {
  const [role, setRole] = useState(roleId);
  const [type, setType] = useState(EMPTY_RESOURCE_TYPE);
  const [chosenPermissions, setChosenPermissions] = useState([]);
  const [isUnlimited, setIsUnlimited] = useState(!!data['unlimited?']);
  const [isOverride, setIsOverride] = useState(!!data['override?']);
  const [isGranular, setIsGranular] = useState(false);
  const [chosenOrgs, setChosenOrgs] = useState(
    data.organizations?.map(o => o.id) || []
  );
  const [chosenLocations, setChosenLocations] = useState(
    data.locations?.map(l => l.id) || []
  );
  const {
    show_organizations: showOrgs = false,
    show_locations: showLocations = false,
  } = type;
  const dispatch = useDispatch();

  useEffect(() => {
    if (data.search)
      dispatch(setAutocompleteSearchQuery(data.search, SEARCH_ID));
    // workaround a bug - initial search query is ignored
  }, [data.search, dispatch]);

  const autocompleteQuery = useSelector(state =>
    selectAutocompleteSearchQuery(state, SEARCH_ID)
  );
  const submit = async () => {
    const params = {
      filter: {
        role_id: role,
        search: autocompleteQuery,
        unlimited: isUnlimited,
        override: isOverride,
        permission_ids: chosenPermissions,
        organization_ids: chosenOrgs,
        location_ids: chosenLocations,
      },
    };
    const apiOptions = {
      handleSuccess: () => {
        history.push(`/filters?role_id=${roleId}`);
      },
      errorToast: ({ message }) => message,
      params,
    };
    if (isNew) {
      dispatch(
        APIActions.post({
          url: '/api/v2/filters',
          key: 'POST_FILTERS_FORM',
          successToast: () => __('Created role successfully'),
          ...apiOptions,
        })
      );
    } else {
      dispatch(
        APIActions.put({
          url: `/api/v2/filters/${data.id}`,
          key: 'PUT_FILTERS_FORM',
          successToast: () => __('Edited role successfully'),
          ...apiOptions,
        })
      );
    }
  };
  return (
    <Form className="filter-form">
      {isNew ? (
        <FormGroup label={__('Selected role')}>{roleName}</FormGroup>
      ) : (
        <SelectRole role={role} setRole={setRole} />
      )}
      <SelectResourceType
        type={type}
        setType={newType => {
          setType(newType);
          dispatch(updateController(newType, newType.search_path, SEARCH_ID));
        }}
        setIsGranular={val => {
          setIsGranular(val);
          if (!val) {
            setIsUnlimited(false);
          }
        }}
        defaultType={data.resource_type_label}
      />

      <SelectPermissions
        resourceType={type}
        defaultPermissions={data.permissions}
        setChosenPermissions={setChosenPermissions}
      />
      {(showOrgs || showLocations) && (
        <FormGroup
          label={__('Override?')}
          labelIcon={
            <Popover
              bodyContent={
                <div>
                  {__(
                    'Filters inherit organizations and locations associated with the role by default. If override field is enabled, the filter can override the set of its organizations and locations. Later role changes will not affect such filter.After disabling the override field, the role organizations and locations apply again.'
                  )}
                </div>
              }
            >
              <button
                type="button"
                aria-label="More info for override field"
                onClick={e => e.preventDefault()}
                className="pf-c-form__group-label-help"
              >
                <HelpIcon noVerticalAlign />
              </button>
            </Popover>
          }
        >
          <Checkbox
            isChecked={isOverride}
            onChange={checked => {
              setIsOverride(checked);
            }}
            aria-label="is override"
            id="override-check"
            name="override"
          />
        </FormGroup>
      )}
      {isOverride && (
        <Taxonomies
          showOrgs={showOrgs}
          showLocations={showLocations}
          setChosenOrgs={setChosenOrgs}
          setChosenLocations={setChosenLocations}
          defaultOrgs={data.organizations}
          defaultLocations={data.locations}
        />
      )}
      {isGranular ? (
        <>
          <FormGroup
            label={__('Unlimited?')}
            labelIcon={
              <Popover
                bodyContent={
                  <div>
                    {__(
                      'If the unlimited field is enabled, the filter applies to all resources of the selected type. If the unlimited  field is disabled, you can specify further filtering using Foreman search syntax in the search field. If the role is associated with organizations or locations, the filters are not considered unlimited as they are scoped accordingly.'
                    )}
                  </div>
                }
              >
                <button
                  type="button"
                  aria-label="More info for unlimited field"
                  onClick={e => e.preventDefault()}
                  className="pf-c-form__group-label-help"
                >
                  <HelpIcon noVerticalAlign />
                </button>
              </Popover>
            }
          >
            <Checkbox
              isChecked={isUnlimited}
              onChange={checked => {
                setIsUnlimited(checked);
                dispatch(updateDisability(checked, SEARCH_ID));
              }}
              aria-label="is unlimited"
              id="unlimited-check"
              name="unlimited"
            />
          </FormGroup>
          <FormGroup label={__('Search')} className="filter-form-search">
            <SearchBar
              disabled={!isUnlimited}
              initialQuery={data.search}
              data={{
                controller: type.name,
                autocomplete: {
                  id: SEARCH_ID,
                  url: type.search_path,
                },
              }}
            />
          </FormGroup>
        </>
      ) : (
        <Alert
          variant="info"
          title={__(
            "Selected resource type does not support granular filtering, therefore you can't configure granularity"
          )}
        />
      )}

      <ActionGroup>
        <Button
          variant="primary"
          isDisabled={!chosenPermissions.length}
          onClick={submit}
        >
          {__('Submit')}
        </Button>
        <Button onClick={() => history.goBack()} variant="link">
          {__('Cancel')}
        </Button>
      </ActionGroup>
    </Form>
  );
};

FiltersForm.propTypes = {
  history: PropTypes.object.isRequired,
  roleName: PropTypes.string.isRequired,
  roleId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  isNew: PropTypes.bool.isRequired,
  data: PropTypes.shape({
    search: PropTypes.string,
    resource_type_label: PropTypes.string,
    'unlimited?': PropTypes.bool,
    'override?': PropTypes.bool,
    id: PropTypes.number,
    resource_type: PropTypes.string,
    role: PropTypes.object,
    permissions: PropTypes.arrayOf(PropTypes.object),
    locations: PropTypes.arrayOf(PropTypes.object),
    organizations: PropTypes.arrayOf(PropTypes.object),
  }).isRequired,
};
