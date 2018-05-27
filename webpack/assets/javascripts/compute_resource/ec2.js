import $ from 'jquery';

export function vpcSelected({ value }) {
  const sgSelect = $('select.security_group_ids');
  const securityGroups = JSON.parse(sgSelect.attr('data-security-groups'));
  const subnets = JSON.parse(sgSelect.attr('data-subnets'));
  // eslint-disable-next-line camelcase
  const vpc =
    value !== '' ? subnets[value] : { vpc_id: 'ec2', subnet_name: 'ec2' };

  sgSelect.empty();

  // eslint-disable-next-line camelcase
  securityGroups[vpc.vpc_id].forEach(({ group_id, group_name }) => {
    sgSelect.append(
      $('<option />')
        .val(group_id)
        // eslint-disable-next-line camelcase
        .text(`${group_name} - ${vpc.subnet_name}`)
    );
  });
  sgSelect.multiSelect('refresh');
}
