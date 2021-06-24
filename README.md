# Terminal and Profile setups
Commands I use to setup my terminal for ZSH and TMUX (syntax highlighting, tmux pane logging, etc) with profile shortcuts.

## zsh_tmux.sh
Clicks script to quickly setup terminal look and feel with the adequate zsh & tmux plugins. (DO NOT RUN SCRIPT AS IS - just do one line at a time in the terminal)

## profile
Command shortcuts I usually have in my shell profile. I'm always running these commands and wanted some quick aliases. You must modify the SECLISTS variable to include the full path to SecLists.

These aliases are either custom made from myself or modifed/copied from others, as mentioned in [Acknowledgments](#Acknowledgments). 

### Setup
Save contents of `profile` into your `~/.bash_profile` for bash:
```bash
curl https://raw.githubusercontent.com/ibr0wse/shell_profile/main/profile >> ~/.bash_profile
```
OR `~/.zprofile` for zsh:
```bash
curl https://raw.githubusercontent.com/ibr0wse/shell_profile/main/profile >> ~/.zprofile
```
Reload shell after running one of the above commands.

### Acknowledgments

##### amass,crt.sh,httprobe
* [@nahamsec](https://github.com/nahamsec)
* Bug bounty recon profile
    * [recon_profile](https://github.com/nahamsec/recon_profile)
##### Grep somefile.gnmap shortcuts
* [@leonjza](https://github.com/leonjza)
* A collection of awesome, grep-like commands for the nmap greppable output 
    * [awesome-nmap-grep](https://github.com/leonjza/awesome-nmap-grep)
