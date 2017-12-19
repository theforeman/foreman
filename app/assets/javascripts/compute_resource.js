function providerSelected(item) {
  tfm.tools.deprecate('providerSelected', 'tfm.computeResource.providerSelected', '1.18');
  tfm.computeResource.providerSelected(item);
}

function testConnection(item) {
  tfm.tools.deprecate('testConnection', 'tfm.computeResource.testConnection', '1.18');
  tfm.computeResource.testConnection(item);
}

function capacity_edit(item) {
  tfm.tools.deprecate('capacity_edit', 'tfm.computeResource.capacityEdit', '1.18');
  tfm.computeResource.capacityEdit(item);
}
