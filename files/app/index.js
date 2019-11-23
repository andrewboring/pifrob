const path = require('path');
const BROWSER = path.join(__dirname, 'browse');
const WWW = path.join(__dirname, 'static');
//const WWW = process.cwd();
// be sure requests and paths
// are from WWW and not the user root.
process.chdir(WWW);
const express = require('express');
const server = express();
server.use(express.static(WWW));
server.listen(8080, () => {
  const child = require('child_process').spawn(
    BROWSER,
    [
      '--fullscreen',
      process.argv[2] || 'http://localhost:8080/'
    ],
    {stdio: 'inherit'}
  );
  child.once('exit', code => process.exit(code || 0));
  process.once('exit', () => child.kill());
});
