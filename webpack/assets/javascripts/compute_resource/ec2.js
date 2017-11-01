/* eslint-disable camelcase */
import $ from 'jquery';

export function vpcSelected({ value }) {
  const sgSelect = $('select.security_group_ids');
  const securityGroups = JSON.parse(sgSelect.attr('data-security-groups'));
  const subnets = JSON.parse(sgSelect.attr('data-subnets'));
  const vpc =
    value !== '' ? subnets[value] : { vpc_id: 'ec2', subnet_name: 'ec2' };

  sgSelect.empty();

  securityGroups[vpc.vpc_id].forEach(({ group_id, group_name }) => {
    sgSelect.append(
      $('<option />')
        .val(group_id)
        .text(`${group_name} - ${vpc.subnet_name}`)
    );
  });
  sgSelect.multiSelect('refresh');
}
