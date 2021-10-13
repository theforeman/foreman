/* eslint-disable jquery/no-text */
/* eslint-disable jquery/no-val */

import $ from 'jquery';

export function vpcSelected({ value }) {
  const sgSelect = $('select.security_group_ids');
  const securityGroups = JSON.parse(sgSelect.attr('data-security-groups'));
  const subnets = JSON.parse(sgSelect.attr('data-subnets'));
  const vpc =
    value !== '' ? subnets[value] : { vpc_id: 'ec2', subnet_name: 'ec2' };

  sgSelect.empty();

  securityGroups[vpc.vpc_id].forEach(
    ({ group_id: groupdId, group_name: groupName }) => {
      sgSelect.append(
        $('<option />').val(groupdId).text(`${groupName} - ${vpc.subnet_name}`)
      );
    }
  );
  sgSelect.multiSelect('refresh');
}
