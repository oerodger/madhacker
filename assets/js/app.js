// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"
import xtcss from "xterm/dist/xterm.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

import { Terminal } from 'xterm';

let term = new Terminal();

term.open(document.getElementById('xterm-container'));
term.focus();

term.prompt = () => {
  term.write('\r\n$ ');
};

term.writeln('Welcome to xterm.js');
term.writeln('This is a local terminal emulation, without a real terminal in the back-end.');
term.writeln('Type some keys and commands to play around.');
term.writeln('');
term.prompt();

term.onKey((e) => {
  const ev = e.domEvent;
  const printable = !ev.altKey && !ev.ctrlKey && !ev.metaKey;

  if (ev.keyCode === 13) {
    term.prompt();
  } else if (ev.keyCode === 8) {
   // Do not delete the prompt
    if (term._core.buffer.x > 2) {
      term.write('\b \b');
    }
  } else if (printable) {
    term.write(e.key);
  }
});
