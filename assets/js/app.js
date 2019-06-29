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
//Terminal.applyAddon(fit);

let term = new Terminal({
  disableStdin: true,
  scrollback: 0,
  cursorStyle: "block"
});

term.open(document.getElementById('xterm-container'));
term.toggleFullScreen(true);
//term.fit();

term.getInputLine = () => {
  return term.buffer.getLine(term._inputLine).translateToString(true, 2);
};

term.toggleInput = (inputEnabled) => {
  term._inputEnabed = !!inputEnabled;

  if (inputEnabled) {
    term.focus();
    term.setOption("cursorStyle", "block");
  } else {
    term.blur();
    term.setOption("cursorStyle", "underline");
  }
};

term.prompt = (message = '') => {
  term.writeln(message);
  term.write('$ ');
  term._inputLine = term.buffer.baseY + term.buffer.cursorY;
};

term.writeln('Welcome to M@DHACKER');
term.writeln('This game will drive you mad or make you a real hacker %)');
term.writeln('');

term.prompt();

/*
term.onData((dataStr) => {
  setTimeout(() => term.write("ECHO: " + dataStr), 100);
});
*/

term.onKey((e) => {
  const ev = e.domEvent;
  const printable = !ev.altKey && !ev.ctrlKey && !ev.metaKey;

  ev.preventDefault();
  ev.stopPropagation();

  if (term._inputEnabed === false) {
    return;
  }

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
  if (typeof data === "string") {
    let command = data.trim().split(" ");
    if (command.length > 0) {
      term.writeln('');
      commandProcessor.exec(command);
    }
  }

  // term.writeln('');
  // term.write("ECHO: " + data);
  //  + " ||| "
  // + JSON.stringify({ inpL: term._inputLine, len: term.buffer.length, rows: term.rows, curY: term.buffer.cursorY, baseY: term.buffer.baseY }));
});

// FOR DEBUG
window.TheTerm = term;
window.onresize = () => {
  term.refresh();
}

let commandProcessor = (function (xterm) {
  let execCommand = (cmdAll) => {
    let command = cmdAll[0];
    let cmdArgs = cmdAll.slice(1);
    let cmd = command.toLowerCase();
    switch (cmd) {
      case "clear":
        xterm.clear();
        break;
      case "color":
        xterm.writeln('\x1b[38;31mTRUECOLOR\x1b[0m');
        break;
      case "hello":
        xterm.toggleInput(false);
        setTimeout(() => {
          xterm.prompt("Hello, " + (cmdArgs && cmdArgs.length > 0 ? cmdArgs.join(" ") : "<unknown stranger>"));
          xterm.toggleInput(true);
        });
        break;
      case "login":
        if (cmdArgs.length > 0) {
          let userLogin = cmdArgs[0];
          if (userLogin.trim() === '') {
            xterm.writeln("Err: provide you name!");
            break;
          }
          xterm.toggleInput(false);
          fetch("/api/user/new?login=" + userLogin).then((resp) => resp.json()).then((authInfo) => {
            xterm._authInfo = authInfo;
            xterm.prompt("AUTH DONE: " + JSON.stringify(authInfo));
            xterm.toggleInput(true);
          });
        } else {
          xterm.writeln("Err: provide you name!");
        }
        break;
      case "join":
        if (!xterm._authInfo) {
          xterm.writeln("Err: login yourself first!");
          break;
        }
        xterm.toggleInput(false);

        // Now that you are connected, you can join channels with a topic:
        let channel = socket.channel("user:" + xterm._authInfo.token, {});
        channel.join()
          .receive("ok", resp => {
            console.log("user channel connected");

            channel.on("game:started", resp => {

              console.log(resp);

              if (intvl) clearInterval(intvl);
              xterm.writeln('\b Done!');
              xterm.writeln('');
              xterm.write('\x1b[38;2;0;255;0mCONNECTED\x1b[0m');
              xterm.writeln(" !!! Joined game successfully, start hacking now !!!");
              xterm.toggleInput(true);
              xterm.prompt();
            });

            channel.push("match:join");

            let counter = 0;
            let intvl;

            xterm.write("Connecting gameframe : ");
            intvl = setInterval(() => {
              let indx = counter++;
              if (indx > 3) {
                counter = 0;
                indx = 0;
              }
              xterm.write('\b' + ['\\', '|', '/', '-'][indx]);
            }, 150);
          })
          .receive("error", resp => {
            xterm.prompt("\b !ERROR!");
          });
        break;
      default:
        xterm.writeln('You said: "' + cmdAll.join(" ") + '"')
        break;
    }
  };

  return {
    exec: execCommand
  };
})(term);

term.focus();
