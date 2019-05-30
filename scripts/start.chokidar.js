#!/usr/bin/env node

const { execSync } = require('child_process');
const chokidar = require('chokidar');

const start = () => {
  console.log('go');
  execSync('run-s build:* test:ea test:scripts');
};

start();

chokidar
  .watch(['./src/**/*.adoc', './src/**/*.json', './src/**/*.js', './scripts/*'])
  .on('change', () => start());
