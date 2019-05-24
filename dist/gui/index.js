const fs = require('fs');
const path = require('path');
const locales = path.join(__dirname, 'locales');
const docs = path.join(__dirname, 'docs');
const exportLocales = {};
const exportDocs = {};

/*
fs.readdirSync(ea).forEach(file => {
  const locale = file.split('.')[0].split('-')[0];
  exportLocales[locale] = Object.assign(exportLocales[locale] || {}, require(path.join(ea, file)));
});

fs.readdirSync(docs).forEach(file => {
  exportDocs[file] = require(path.join(docs, file));
});
*/
fs.readdirSync(locales).forEach(file => {
  if (/locales/i.test(file)) {
    exportLocales.locales = require(path.join(locales, file));
  } else {
    const fileName = file.split('.')[0].split('-')[0];

    exportLocales[fileName] = Object.assign(
      exportLocales[fileName] || {},
      require(path.join(locales, file))
    );
  }
});

fs.readdirSync(docs).forEach(file => {
  const fileName = file.split('.')[0];
  exportDocs[fileName] = fs.readFileSync(path.join(docs, file), 'utf8');
});

module.exports = {
  locales: exportLocales,
  docs: exportDocs
};
