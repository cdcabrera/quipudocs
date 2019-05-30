#!/usr/bin/env node

const { execSync } = require('child_process');
const nodeWatch = require('node-watch');

const start = () => {
  execSync('run-s build:* test:ea test:scripts');
};

try {
  nodeWatch.close();
} catch (e) {
  console.warn(`Node Watch: ${e.message}`);
}

start();

nodeWatch(['./src', './scripts'], { recursive: true }, () => start());
