import React from 'react';
import { translate as __ } from '../../../common/I18n';

import ForemanForm from '../../../components/common/forms/ForemanForm';
import TextField from '../../../components/common/forms/TextField';

const hwModelHelp = __("The class of CPU supplied in this machine. This is primarily used by Sparc Solaris builds and can be left blank for other architectures. The value can be determined on Solaris via uname -m")
const vendorClassHelp = __("The class of the machine reported by the Open Boot Prom. This is primarily used by Sparc Solaris builds and can be left blank for other architectures. The value can be determined on Solaris via uname -i|cut -f2 -d,")
const infoHelp = __("General useful description, for example this kind of hardware needs a special BIOS setup")

const ModelForm = props => {
  return (
    <ForemanForm
      onSubmit={(values, actions) => {}}
      initialValues={props.initialValues}
      onCancel={() => {}}
    >
      <TextField name="name" type="text" required="true" label={__('Name')} />
      <TextField name="hardwareModel" type="text" label={__('Hardware Model')} helpBlock={hwModelHelp} />
      <TextField name="vendorClass" type="text" label={__('Vendor Class')} helpBlock={vendorClassHelp} />
      <TextField name="info" type="textarea" label={__('Information')} helpBlock={infoHelp} />
    </ForemanForm>
  )
}

export default ModelForm;
