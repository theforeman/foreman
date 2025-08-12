import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch } from 'react-redux';
import {
  Form,
  FormGroup,
  Alert,
  ActionGroup,
  Button,
  TextInput,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';
import { translate as __ } from '../../common/I18n';
import SearchBar from '../../components/SearchBar';
import './FilterForm.scss';
import { SelectPermissions } from './SelectPermissions';
import { SelectResourceType } from './SelectResourceType';
import { SelectRole } from './SelectRole';
import { EMPTY_RESOURCE_TYPE, SEARCH_ID } from './FiltersFormConstants';
import { APIActions } from '../../redux/API';
import { addToast } from '../../components/ToastsList';

export const FiltersForm = ({ roleName, roleId, isNew, data, history }) => {
  const [role, setRole] = useState(roleId);
  const [type, setType] = useState(EMPTY_RESOURCE_TYPE);
  const [chosenPermissions, setChosenPermissions] = useState([]);
  const [isGranular, setIsGranular] = useState(false);
  const chosenOrgs = data?.role?.organizations?.map(o => o.name) || [];
  const chosenLocations = data?.role?.locations?.map(l => l.name) || [];

  const dispatch = useDispatch();
  const [autocompleteQuery, setAutocompleteQuery] = useState(data.search || '');
  const submit = async () => {
    const params = {
      filter: {
        role_id: role,
        search: autocompleteQuery,
        permission_ids: chosenPermissions,
      },
    };
    const apiOptions = {
      handleSuccess: () => {
        history.push(`/filters?role_id=${roleId}`);
      },
      handleError: ({ response }) => {
        dispatch(
          addToast({
            sticky: true,
            type: 'danger',
            // eslint-disable-next-line camelcase
            message: response?.data?.error?.full_messages[0] || '',
            key: 'role_edit_failure',
          })
        );
      },
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
        }}
        setIsGranular={val => {
          setIsGranular(val);
        }}
        defaultType={data.resource_type}
        setAutocompleteQuery={setAutocompleteQuery}
      />

      <SelectPermissions
        resourceType={type}
        defaultPermissions={data.permissions}
        setChosenPermissions={setChosenPermissions}
      />
      <FormGroup label={__('Organizations')}>
        <TextInput
          ouiaId="filter-org-text-disabled"
          aria-label="disabled organization field"
          isDisabled
          type="text"
          value={chosenOrgs.join(', ')}
        />
        <FormHelperText>
          <HelperText>
            <HelperTextItem>
              {__('Organizations are inherited from the role')}
            </HelperTextItem>
          </HelperText>
        </FormHelperText>
      </FormGroup>
      <FormGroup label={__('Locations')}>
        <TextInput
          aria-label="disabled location field"
          ouiaId="filter-location-text-disabled"
          isDisabled
          type="text"
          value={chosenLocations.join(', ')}
        />
        <FormHelperText>
          <HelperText>
            <HelperTextItem>
              {__('Locations are inherited from the role')}
            </HelperTextItem>
          </HelperText>
        </FormHelperText>
      </FormGroup>
      {isGranular ? (
        <>
          <FormGroup label={__('Search')} className="filter-form-search">
            <SearchBar
              initialQuery={data.search}
              data={{
                controller: type.name,
                autocomplete: {
                  searchQuery: autocompleteQuery,
                  id: SEARCH_ID,
                  url: type.search_path,
                },
              }}
              onSearch={null}
              onSearchChange={setAutocompleteQuery}
            />
          </FormGroup>
        </>
      ) : (
        <Alert
          ouiaId="granular-filtering-alert"
          variant="info"
          title={__(
            "Selected resource type does not support granular filtering, therefore you can't configure granularity"
          )}
        />
      )}

      <ActionGroup>
        <Button
          ouiaId="filters-submit-button"
          variant="primary"
          isDisabled={!chosenPermissions.length}
          onClick={submit}
        >
          {__('Submit')}
        </Button>
        <Button
          ouiaId="filters-cancel-button"
          onClick={() => history.goBack()}
          variant="link"
        >
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
    id: PropTypes.number,
    resource_type: PropTypes.string,
    role: PropTypes.object,
    permissions: PropTypes.arrayOf(PropTypes.object),
  }).isRequired,
};
