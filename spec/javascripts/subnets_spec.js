//= require subnets

describe('showSubnetIPAM', function() {
  it('hides options when auto-suggest is on', function() {
    loadFixtures('subnets_ipam.html');
    expect($('#ipam_options')[0].className).not.toContain('hide');
    showSubnetIPAM($('#subnet_ipam'));
    expect($('#ipam_options')[0].className).toContain('hide');
  });
});
