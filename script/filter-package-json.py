#!/usr/bin/env python3

import argparse
import json

parser = argparse.ArgumentParser(description='Filter unneeded dependencies from package.json')
parser.add_argument('--package-json', dest='package_json', action='store',
                    default='package.json',
                    help='path to package.json (default: %(default)s)')
parser.add_argument('--package-exclude', dest='package_exclude', action='store',
                    default='package-exclude.json',
                    help='path to package-exclude.json (default: %(default)s)')

args = parser.parse_args()

# We need a list of packages that are devDependencies but not needed to build
with open(args.package_exclude) as package_exclude:
    excludes = json.load(package_exclude)

def is_excluded(package):
    return (package in excludes['EXCLUDE_NPM_PACKAGES']
            or any(package.startswith(prefix) for prefix in excludes['EXCLUDE_NPM_PREFIXES']))

def filter_dependencies(deps):
    return {package: version for package, version in sorted(deps.items()) if not is_excluded(package)}

with open(args.package_json) as package_json:
    data = json.load(package_json)
for section in ('devDependencies', 'dependencies'):
    data[section] = filter_dependencies(data.get(section, {}))

with open(args.package_json, 'w') as package_json:
    json.dump(data, package_json, indent=2)
