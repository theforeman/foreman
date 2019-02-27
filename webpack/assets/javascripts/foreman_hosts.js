import { uniq, set } from 'lodash';
import $ from 'jquery';

import store, { observeStore } from './react_app/redux';

import { fixTemplateNames } from './foreman_nested_forms';
import * as breadcrumbs from './foreman_breadcrumbs';
import * as interfaceActions from './react_app/redux/actions/hosts/interfaces';

const pluginEditAttributes = {
  architecture: [],
  os: [],
  medium: [],
  image: [],
};

export function registerPluginAttributes(componentType, attributes) {
  if (pluginEditAttributes[componentType] !== undefined) {
    const combinedAttributes = pluginEditAttributes[componentType].concat(
      attributes
    );
    pluginEditAttributes[componentType] = uniq(combinedAttributes);
  }
}

export function getAttributesToPost(componentType) {
  const defaultAttributes = {
    architecture: ['architecture_id', 'organization_id', 'location_id'],
    os: ['operatingsystem_id', 'organization_id', 'location_id'],
    medium: ['medium_id', 'operatingsystem_id', 'architecture_id'],
    image: ['medium_id', 'operatingsystem_id', 'architecture_id', 'model_id'],
  };
  let attrsToPost = defaultAttributes[componentType];

  if (attrsToPost === undefined) {
    return [];
  }
  if (pluginEditAttributes[componentType] !== undefined) {
    attrsToPost = attrsToPost.concat(pluginEditAttributes[componentType]);
  }
  return uniq(attrsToPost);
}

export const fqdn = (name, domain) => {
  if (!name || !domain) return '';

  return `${name}.${domain}`;
};

export const createInterfaceHiddenWrapper = interfaceId => {
  const interfaceHidden = document.createElement('div');
  interfaceHidden.id = `interfaceHidden${interfaceId}`;
  interfaceHidden.className = 'hidden';
  interfaceHidden.dataset.interfaceId = interfaceId;

  document.getElementById('interfaceForms').appendChild(interfaceHidden);
  return interfaceHidden;
}

export const getInterfaceHiddenFields = interfaceId =>
  document.getElementById(`interfaceHidden${interfaceId}`) ||
    createInterfaceHiddenWrapper(interfaceId);

const updateInterfaceHiddenForms = (state, prevState) => {
  const pathname = window.location.pathname;

  state.interfaces.forEach((interfaceData, idx) => {
    const prevData = prevState.interfaces.filter(i => i.id == interfaceData.id)[0];
    if (prevData && prevData === interfaceData) return;

    const hiddenFields = getInterfaceHiddenFields(interfaceData.id);
    const nameEl = hiddenFields.getElementsByClassName('interface_name')[0];
    const primaryCheck = hiddenFields.getElementsByClassName('interface_primary')[0];
    const provisionCheck = hiddenFields.getElementsByClassName('interface_provision')[0];
    const virtualCheck = hiddenFields.getElementsByClassName('virtual')[0];

    nameEl.value = interfaceData.name;
    primaryCheck.checked = interfaceData.primary;
    provisionCheck.checked = interfaceData.provision;
    virtualCheck.checked = interfaceData.virtual;

    if (interfaceData.primary) {
      $('#host_name').val(interfaceData.name);

      const fqdnVal = fqdn(interfaceData.name, interfaceData.domain);
      if (fqdnVal.length > 0 && pathname === '/hosts/new') {
        breadcrumbs.updateTitle(__("Create Host") + " | " + fqdnVal);
      }
    }

    if (interfaceData.editing) {
      showEditInterfaceModal(interfaceData.id);
    }

    if (!interfaceData.providerSpecificInfo) {
      const providerSpecificInfo = window.providerSpecificInterfaceInfo($(hiddenFields));
      if (providerSpecificInfo)
      tfm.hosts.updateInterface(interfaceData.id, { providerSpecificInfo });
    }
  });
  state.destroyed.forEach((destroyedId, idx) => {
    $('#interfaceHidden'+destroyedId+' .destroyFlag').val(1);
  });
}
observeStore(updateInterfaceHiddenForms, store => store.hosts.interfaces);

function getInterfaceFormTemplateClone() {
  var content = $('#interfaces .interfaces_fields_template').html();
  var interfaceId = new Date().getTime();

  content = fixTemplateNames(content, 'interfaces', interfaceId);

  var hidden = $(content);

  $('#interfaceForms').closest("form").trigger({ type: 'nested:fieldAdded', field: hidden });
  $('a[rel="popover"]').popover();
  $('a[rel="twipsy"]').tooltip();

  hidden.attr('id', 'interfaceHidden'+interfaceId);
  hidden.data('interface-id', interfaceId);
  hidden.find('.destroyFlag').val(0);

  return hidden;
}

const showInterfaceModal = ($form, newInterface = false) => {
  $('#interfaceModal').data('new-interface', newInterface);
  window.show_interface_modal($form);
};

export const showEditInterfaceModal = interfaceId => {
  const $form = $(getInterfaceHiddenFields(interfaceId)).clone(true);
  showInterfaceModal($form, false);
};

export const showNewInterfaceModal = () => {
  const $form = getInterfaceFormTemplateClone();
  showInterfaceModal($form, true);
};

export const getInterfacesData = () => store.getState().hosts.interfaces;

export const initializeInterfaces = interfaces => {
  store.dispatch(interfaceActions.initializeInterfaces(interfaces));
};

export const addInterface = (data = {}) => {
  store.dispatch(interfaceActions.addInterface(data));
};

export const updateInterface = (id, newValues) => {
  store.dispatch(interfaceActions.updateInterface(id, newValues));
};

export const removeInterface = id => {
  store.dispatch(interfaceActions.removeInterface(id));
};

export const setPrimaryInterface = id => {
  store.dispatch(interfaceActions.setPrimaryInterface(id));
};

export const setProvisionInterface = id => {
  store.dispatch(interfaceActions.setProvisionInterface(id));
};

export const setPrimaryInterfaceName = newName => {
  store.dispatch(interfaceActions.setPrimaryInterfaceName(newName));
};

class PXECompatibilityCheck {
  constructor(regexp, compatibleLoadersFunc) {
    this.__regexp = regexp;
    this.__compatibleLoadersFunc = compatibleLoadersFunc;
  }

  isCompatible(osTitle, pxeLoader) {
    const os = this.__regexp.exec(osTitle);

    if (os == null) {
      return null;
    }

    const supportedLoaders = this.__compatibleLoadersFunc(os);
    if (supportedLoaders != null) {
      return supportedLoaders.indexOf(pxeLoader) > -1;
    }
    return null;
  }
}

/* eslint-disable no-unused-vars */
const PXE_BIOS = 'PXELinux BIOS';
const PXE_UEFI = 'PXELinux UEFI';
const GRUB_UEFI = 'Grub UEFI';
const GRUB2_UEFI = 'Grub2 UEFI';
const GRUB2_UEFI_SB = 'Grub2 UEFI SecureBoot';

export const pxeCompatibility = {};

// Ubuntu 10.x or older and Grub1
// Ubuntu 11.x or newer and Grub2
set(
  pxeCompatibility,
  'ubuntu',
  new PXECompatibilityCheck(/ubuntu[^\d]*(\d+)(?:[.]\d+)?/, os => {
    if (os[1] <= '10') {
      return [PXE_BIOS, GRUB_UEFI];
    } else if (os[1] > '10') {
      return [PXE_BIOS, GRUB2_UEFI, GRUB2_UEFI_SB];
    }
    return null;
  })
);

// RHEL 6.x and Grub1
// RHEL 7.x and Grub2
set(
  pxeCompatibility,
  'rhel',
  new PXECompatibilityCheck(
    /(?:red[ ]*hat|rhel|cent[ ]*os|scientific|oracle)[^\d]*(\d+)(?:[.]\d+)?/,
    os => {
      if (os[1] === '6') {
        return [PXE_BIOS, GRUB_UEFI];
      } else if (os[1] >= '7') {
        return [PXE_BIOS, GRUB2_UEFI, GRUB2_UEFI_SB];
      }
      return null;
    }
  )
);

// Debian 2-6 and Grub1
// Debian 7+ and Grub2
set(
  pxeCompatibility,
  'debian',
  new PXECompatibilityCheck(/debian[^\d]*(\d+)(?:[.]\d+)?/, os => {
    if (os[1] >= '2' && os[1] <= '6') {
      return [PXE_BIOS, GRUB_UEFI];
    } else if (os[1] > '6') {
      return [PXE_BIOS, GRUB2_UEFI, GRUB2_UEFI_SB];
    }
    return null;
  })
);

export function checkPXELoaderCompatibility(osTitle, pxeLoader) {
  if (pxeLoader === 'None' || pxeLoader === '') {
    return null;
  }
  let compatible = null;

  // eslint-disable-next-line no-param-reassign
  osTitle = osTitle.toLowerCase();
  Object.values(pxeCompatibility).forEach(check => {
    const compatibleCheck = check.isCompatible(osTitle, pxeLoader);

    if (compatibleCheck != null) {
      compatible = compatibleCheck;
    }
  });
  return compatible;
}
