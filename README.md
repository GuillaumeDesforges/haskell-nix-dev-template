# Haskell Nix dev template
A template for completely reproducile build and development in Haskell using Nix.

## How to use

### Dependencies

1. Install Nix

Please find the documentation here: [https://nixos.org/nix/manual/#chap-installation](https://nixos.org/nix/manual/#chap-installation)

TL;DR
```bash
bash <(curl https://nixos.org/nix/install)
```

2. Install VS Code and some plugins:
    * `Nix Environment Selector`
    * `Haskell Syntax Highlighting`
    * Either `ghcide` for ghcide (default) or `Haskell Language Server` for HIE (slower but has a bit more tools)

#### Recommanded steps for faster use

Nix will compile everything that is not in the cache, especially HIE, GHCIDE, etc.
In order to build the environment faster, please use Cachix.

2. Install Cachix

```bash
nix-env -iA cachix -f https://cachix.org/api/v1/install
```

3. Add caches for this project

```bash
cachix use all-hies
cachix use hercules-ci
```

### Get started

1. Clone this repository

```bash
git clone https://github.com/GuillaumeDesforges/haskell-nix-dev-template.git
cd haskell-nix-dev-template
```

2. Build the environment for the first time
    * Wait for the build to complete. It can be very long but don't worry, it will work almost instantly next time.

```bash
nix-shell --run "echo Sucessfully built the environment"
```

3. Start VS Code

```bash
code .
```

4. Use `Nix Environment Selector` (bottom left of the VS Code window, in the toolbar) to select `shell.nix` as the environment.
    * Reload the VS Code window when asked (a notification will pop up at the bottom right of the window).

5. You can now create projects (Cabal packages) in the `./packages` directory.

Repeat from step (2) when you add, remove or modify a `.cabal` file.

### Configuration

Some parameters can be configured by editing the file `./nix/confgi.nix`. 

For now you can:
* Change the GHC version to use
    * Warning: check that this version is supported by nixpkgs and your IDE
* Select the IDE used
    * For now either ghcide (default) or HIE

### Extra dependencies

In some cases, you might need to use Haskell packages that are not on Nixpkgs.
This goes beyond the scope of this template.
However here is some information to achieve that:

0. *WARNING*: You need to know how to write Nix expressions and how Haskell packages are built on Nixpkgs
1. Look [here](https://github.com/fghibellini/nix-haskell-monorepo/tree/master/extra-deps) for a guide on how to write extra dependencies
2. Write those extra dependencies in the `./nix/extra-deps.nix` file

Note: don't forget to add those dependencies in your `.cabal` file or else it won't be added.

## Motivations

I found setting up a Haskell project way more complicated than nearly any modern language.
I decided to make once and for all a way for beginners such as myself to start playing with Haskell quickly without spending so much time thinking about the IDE.

## The philosophy

1. The development can be started after only a few commands in CLI.
2. Use Nix to handle packages (Haskell compiler, development tools).
3. Use Cabal for the Haskell package definition.
3. Use VS Code to write code.

**Please note that this is not educational content.**

It is not a reference, nor is it readable for a beginner in Nix.
It just gets the job done enough in order to spend less time on setting up an environment **as a beginner**.

## Credits

Huge credits to [https://github.com/fghibellini/nix-haskell-monorepo/](https://github.com/fghibellini/nix-haskell-monorepo/).
You must go there if you want to go any futher into Haskell & Nix from this repo.
