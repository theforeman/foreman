#!/usr/bin/env python3

import json

# We need a list of packages that are devDependencies but not needed to build
with open('package-exclude.json') as package_exclude:
    excludes = json.load(package_exclude)

def is_excluded(package):
    return (package in excludes['EXCLUDE_NPM_PACKAGES']
            or any(package.startswith(prefix) for prefix in excludes['EXCLUDE_NPM_PREFIXES']))

def filter_dependencies(deps):
    return {package: version for package, version in sorted(deps.items()) if not is_excluded(package)}

with open('package.json') as package_json:
    data = json.load(package_json)
for section in ('devDependencies', 'dependencies'):
    data[section] = filter_dependencies(data.get(section, {}))

with open('package.json', 'w') as package_json:
    json.dump(data, package_json, indent=2)
