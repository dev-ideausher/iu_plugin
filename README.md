# IU Plugin

Assuming you have done all the steps mentioned [here](https://github.com/dev-ideausher/iu.cli-master#readme), this is the plugin which we will use to generate the code template.

## Installation

installing the plugin rightaway :

```
fast plugin add git https://github.com/dev-ideausher/iu_plugin.git
```

After that, you need to set the Environmental path variable:

- for MacOS 

```
export PATH="$PATH:/Users/"yourpcname"/.fastcli/bin"
```

To setup services, dio, etc. and dependencies required with them, run :

```
iu run velo
```

To setup firebase auth functions, run :

```
iu run auth
```

To remove the plugin :

```
fast plugin remove --name iu
```

To list the plugins installed :

```
fast plugin list
```

<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<sub><sub><sub>please dont ask me what is IU 🥹</sub></sub></sub>
