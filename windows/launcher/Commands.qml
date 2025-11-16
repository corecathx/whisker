pragma Singleton
import Quickshell
import qs.modules
Singleton {
  property var commands: [
      {
          trigger: "/calc",
          name: "Calculator",
          icon: "calculate",
          comment: "Perform quick math calculations",
          mode: "inline",
          exec: function(input) {
              const expr = input.replace("/calc", "").trim();
              if (!expr) return "Enter an expression";
              try {
                  return eval(expr);
              } catch(e) {
                  return "Invalid syntax: " + e.message;
              }
          }
      },
      {
          trigger: "/web",
          name: "Web Search",
          icon: "search",
          comment: "Search on Google",
          mode: "inline",
          exec: function(input) {
              const query = input.replace("/web", "").trim();
              if (!query) return "Enter a search query";
              return "Press Enter to search for: " + query;
          },
          onExecute: function(input) {
              const query = input.replace("/web", "").trim();
              if (query) {
                  Quickshell.execDetached({
                      command: ["xdg-open", "https://www.google.com/search?q=" + encodeURIComponent(query)]
                  });
              }
          }
      },
      {
          trigger: "/hi",
          name: "Hello",
          icon: "waving_hand",
          comment: "Say hello!",
          mode: "direct",
          exec: function(input) {
              Quickshell.execDetached({
                  command: [
                      "whisker",
                      "notify",
                      "Whisker",
                      "Hello, " + Quickshell.env("USER") + "!"
                  ]
              });
              return null;
          }
      },
      {
          trigger: "/theme",
          name: "Theme Settings",
          icon: "palette",
          comment: "Configure theme settings",
          mode: "menu",
          menu: [
              {
                  name: "Mode",
                  icon: "whisker:dark_mode",
                  comment: "Switch between light and dark mode",
                  submenu: [
                      {
                          name: "Light Mode",
                          icon: "whisker:light_mode",
                          comment: "Switch to light theme",
                          exec: function() {
                              Quickshell.execDetached({
                                  command: ["whisker", "prefs", "set", "theme.dark", false]
                              });
                              Quickshell.execDetached({
                                  command: ["whisker", "notify", "Whisker", "Light mode enabled!"]
                              });
                          }
                      },
                      {
                          name: "Dark Mode",
                          icon: "whisker:dark_mode",
                          comment: "Switch to dark theme",
                          exec: function() {
                              Quickshell.execDetached({
                                  command: ["whisker", "prefs", "set", "theme.dark", true]
                              });
                              Quickshell.execDetached({
                                  command: ["whisker", "notify", "Whisker", "Dark mode enabled!"]
                              });
                          }
                      }
                  ]
              }
          ]
      },
      {
          trigger: "/power",
          name: "Power",
          icon: "power",
          comment: "Power related commands",
          mode: "menu",
          menu: [
              {
                  name: "Power off",
                  icon: "whisker:power_settings_new",
                  exec: function() {
                      Quickshell.execDetached({
                          command: ["whisker", "ipc", "power", "off"]
                      });
                  }
              },
              {
                  name: "Reboot",
                  icon: "whisker:restart_alt",
                  exec: function() {
                      Quickshell.execDetached({
                          command: ["whisker", "ipc", "power", "reboot"]
                      });
                  }
              },
              {
                  name: "Suspend",
                  icon: "whisker:bedtime",
                  exec: function() {
                      Quickshell.execDetached({
                          command: ["whisker", "ipc", "power", "suspend"]
                      });
                  }
              },
          ]
      }
  ];

  function getMatchedCommand(query) {
      const trimmed = query.trim();
      for (let i = 0; i < commands.length; i++) {
          if (trimmed.startsWith(commands[i].trigger)) {
              return commands[i];
          }
      }
      return null;
  }

  function getCommandSuggestions(query) {
      const trimmed = query.trim().toLowerCase();
      if (!trimmed.startsWith("/")) return [];

      var suggestions = [];
      for (let i = 0; i < commands.length; i++) {
          if (commands[i].trigger.toLowerCase().startsWith(trimmed)) {
              suggestions.push(commands[i]);
          }
      }
      return suggestions;
  }

}
