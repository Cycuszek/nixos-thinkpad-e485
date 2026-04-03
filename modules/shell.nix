{ config, pkgs, ... }:
{
  # -------------------------------------------------------
  # ZSH — set as default shell system-wide
  # -------------------------------------------------------
  programs.zsh = {
    enable = true;

    # oh-my-zsh
    ohMyZsh = {
      enable = true;
      theme  = "robbyrussell";   # classic theme, change to your liking
                                  # other popular options: "agnoster", "af-magic", "fino"
      plugins = [
        "git"                    # git aliases and branch in prompt
        "sudo"                   # press ESC twice to prepend sudo
        "dirhistory"             # Alt+Left/Right to navigate directory history
        "copypath"               # copy current path to clipboard
        "copyfile"               # copy file contents to clipboard
      ];
    };

    # Autocompletion + syntax highlighting
    autosuggestions.enable   = true;   # fish-like inline suggestions
    syntaxHighlighting.enable = true;  # color commands as you type

    # Useful aliases
    shellAliases = {
      ll   = "ls -la";
      la   = "ls -A";
      ".." = "cd ..";
      "..." = "cd ../..";
      gs   = "git status";
      gc   = "git commit";
      gp   = "git push";
      gl   = "git log --oneline --graph";
      rebuild = "sudo nixos-rebuild switch --flake .#e485";  # quick rebuild shortcut
    };
  };

  # Set zsh as default shell for user cyc
  users.users.cyc.shell = pkgs.zsh;
}
