#!/bin/bash
set -ev

cd ..
git clone https://github.com/Katello/katello.git
cd katello;
npm install;
npm run test;
npm run lint;
