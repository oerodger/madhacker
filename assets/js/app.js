// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"
import xtcss from "xterm/dist/xterm.css"
import xtfscss from "xterm/src/addons/fullscreen/fullscreen.css"

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
import * as fullscreen from 'xterm/lib/addons/fullscreen/fullscreen';
// import * as fit from 'xterm/lib/addons/fit/fit';

Terminal.applyAddon(fullscreen);
// Terminal.applyAddon(fit);

let term = new Terminal();

term.open(document.getElementById('xterm-container'));
term.toggleFullScreen(true);
// term.fit();

term.focus();

term.getInputLine = () => {
  return term.buffer.getLine(term._inputLine).translateToString(true, 2);
};

term.prompt = () => {
  term.writeln('');
  term.write('$ ');
  term._inputLine = term.buffer.baseY + term.buffer.cursorY;
};

term.writeln('Welcome to M@DHACKER');
term.writeln('This game will drive you mad or make you a real hacker %)');
term.writeln('');

term.prompt();

term.onKey((e) => {
  const ev = e.domEvent;
  const printable = !ev.altKey && !ev.ctrlKey && !ev.metaKey;

  if (ev.keyCode === 13) {
    term.emit("user-input", term.getInputLine());
    term.prompt();
  } else if (ev.keyCode === 38 || ev.keyCode === 40) {
    // Do NOT handle UP or DOWN now
  } else if (ev.keyCode === 8) {
    // Do not delete the prompt
    if (term._core.buffer.x > 2) {
      term.write('\b \b');
    }
  } else if (printable) {
    term.write(e.key);
  }
});

term.onRender(() => {
  term._inputLine = term.buffer.baseY + term.buffer.cursorY;
});

term.on("user-input", (data) => {
  term.writeln('');
  term.write("ECHO: " + data);
  //  + " ||| "
  // + JSON.stringify({ inpL: term._inputLine, len: term.buffer.length, rows: term.rows, curY: term.buffer.cursorY, baseY: term.buffer.baseY }));
});

// FOR DEBUG
window.TheTerm = term;

/*
term.onData((dataStr) => {
  term.write(dataStr);
});
*/
