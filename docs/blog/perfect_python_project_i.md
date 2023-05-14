---
tags:
  - Projects
  - Python projects
  - Bash
  - GitHub Actions
---

# Setting Up a Perfect Python Project (part I) <small>2023-05-14</small>


There are no formal rules on how to setting up a Python project.However there are a series of guidelines, community standards and a Python tutorial on [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/). This is my very opinionated way of setting up a perfect Python project. I try to follow the community standards and the Python tutorial as much as possivel (stands on the shoulders of giants).

Before get started you need to know a bit about my set up in general.
I'm running a linux distro based on [Ubuntu](https://ubuntu.com/) and using a Shell[^1] Bash.

To follow this tutorial in full you need to meet the requirements below. 

## Requirements
- pyenv
- GNU Make
- Bash
- git
- GitHub account

!!! tip
    If you're a Windows user, my suggestion is to install [WSL 2](https://learn.microsoft.com/en-us/windows/wsl/about). With it you get a GNU/Linux environment. Microsoft itself suggests installing Python with WSL for some users.

    Within your WSL Shell you can follow this tutorial seamlessly.

### pyenv
[pyenv](https://github.com/pyenv/pyenv) is a simple Python version Management.
Even though it's recomended to keep your Python version up to date, one day in your python journey you'll get caught up in needing to use different versions of it and then you'll realize that pyenv will make your life much easier.

!!! warning
    pyenv doesn't support Windows, but you can use it within WSL.


### GNU Make
[GNU Make](https://www.gnu.org/software/make/) is a tool which controls the generation of executables and other non-source files of a program. I use it to create entry points to organize commands and scripts that we use a lot during the development process like running tests, generating docs, running linters, etc.

### Git
[Git](https://git-scm.com/) is the most popular VCS and a base ground for developing any sort of software.

### GitHub
[GitHub](https://github.com/) is where you can share your open source projects, as well as use GitHub Actions to automate your CI/CD.

## Setting up the folders

Now that you already have your setup up and running. Let's create the smallest folder structure you need for you project.

Let's call the project *perf_py_project*.

```shell
$ mkdir -p perf_py_project/{perf_py_project,.github/workflows,scripts,tests}
```

`-p` is the shortcut pf `--parents`. Let's see how the folder structure looks like.
```shell
$ tree -a
.
└── perf_py_project
    ├── .github
    │   └── workflows
    ├── perf_py_project
    ├── scripts
    └── tests

```

The first folder is the default GitHub folder where we put all github actions files. The second is where you will save your your own project, the third the scripts to automate some routines and the last one your tests.

## Python setup

Now that we already have the folder structure we can configure Python version and environment.

I also like to set the version using the pyenv's `local` setup, so whenever you go into the folder pyenv will map the right version for you.

When I'm writing this tutorial the newest Python version is *3.11.3*, therefore I'll use it.

```shell
$ cd perf_py_project
/perf_py_project $ pyenv local 3.11.3
```

Let's have another look in the structure.

```shell
$ tree -a
.
├── .github
│   └── workflows
├── perf_py_project
├── .python-version
├── scripts
└── tests

```
Inside the *perf_py_project* root you can see a new file `.python-version`. This file is how pyenv will map your python version.

After setting the python version, let's create the Python environment.

```shell
$ python -m venv .venv
```

I like to call all my environments `.venv`, but this name is up to you. After this command we'll have a new folder called `.venv`.


Let's take a look for sanity's sake.

```shell hl_lines="1"
$ . .venv/bin/activate
(.venv) $ python -V
Python 3.11.3
```

The one highlighted above is the command you need to call every time you want to activate your project environment :rolling_eyes:. Nobody likes to do the same thing over and over and what moves a good programmer is the laziness of doing something manually that can be done programmatically or manually abbreviated.

## Scripts and Makefile

During a Python project, you'll almost certainly be running a bunch of commands over and over again, so it's a good compromise to have some scripts running those commands automatically for you.

The shortest list of scripts you should have is (We'll go through each one in a bit):

- bootstrap.sh
- format.sh
- test.sh
- publish.sh
- docs_preview.sh
- docs_publish.sh

This list is not fixed and you can add new scripts to it if you feel so.

So let's create them though.

```shell hl_lines="1-2"
$ cd scripts/ && echo '#!/usr/bin/env bash' | 
tee bootstrap.sh format.sh test.sh publish.sh docs_preview.sh docs_publish.sh
#!/usr/bin/env bash

```
with the command highlighted above you get into the scripts folder and create all files at once with the shebang[^2] (`#!/usr/bin/env bash`) on top of them. `tee` copy the standard input to each file and print it to the standard output as well.
Let's just check everything.

```shell
/scripts $ tree
.
├── bootstrap.sh
├── docs_preview.sh
├── docs_publish.sh
├── format.sh
├── publish.sh
└── test.sh

0 directories, 6 files

/scripts $ cat -n bootstrap.sh docs_preview.sh docs_publish.sh format.sh publish.sh test.sh 
     1	#!/usr/bin/env bash
     2	#!/usr/bin/env bash
     3	#!/usr/bin/env bash
     4	#!/usr/bin/env bash
     5	#!/usr/bin/env bash
     6	#!/usr/bin/env bash

```
Looks ok. We have 6 files and `cat` prints out 6 shebangs.

It's beyond the scope of this tutorial to discuss bash script, so I'll give a brief explanation of each and you can copy them and check out the scripts themselves later on for yourself. I suggest copying them manually so you can figure out things more easily and understand the logic behind them.

!!! info
    The scripts carry my personal picks in Python libraries for development. You need to be aware of this. Most of these programs I use have some other surrogates and/or generics.

### bootstrap

`bootstrap.sh` sets up your Python environment and installs your program in *editable* mode. It allows you to install your program and have it up and running on the fly, so you can modify and test it seamlessly.

??? example
    ```shell title="bootstrap.sh" linenums="1"
    #!/usr/bin/env bash

    PREFIX=''

    [[ -z "$GITHUB_ACTIONS" ]] && PREFIX='.venv/bin/' && python -m venv .venv 

    ${PREFIX}python -m pip install --upgrade pip flit
    ${PREFIX}python -m flit install --symlink --deps all
    ```

### format
`format.sh` ensures that your code is always formed according to the Python Style Guide.

??? example
    ```shell title="format.sh" linenums="1"
    #!/usr/bin/env bash

    set -e

    PREFIX=''

    [[ -d .venv ]] && PREFIX='.venv/bin/'

    ${PREFIX}python -m black perf_py_project/ tests/
    ${PREFIX}python -m pydocstyle perf_py_project/
    ${PREFIX}python -m isort perf_py_project/ tests/
    ${PREFIX}python -m flake8 perf_py_project/ tests/
    ```

### test
`test.sh` is responsible for running the test suite.

??? example
    ```shell title="test.sh" linenums="1"

    #!/usr/bin/env bash

    set -e
    set -x

    PREFIX=''

    [[ -d .venv ]] && PREFIX='.venv/bin/' && python -m venv .venv

    ${PREFIX}python -m pytest \
        --cov-config=.coveragerc \
        --cov-report \
        term-missing \
        --cov=perf_py_project/ test/
    ```

### publish
`publish.sh` is responsible for publishing your Python project as a package on [PyPI](https://pypi.org/).


??? example
    ```shell title="publish.sh" linenums="1"
    #!/usr/bin/env bash

    set -e

    PREFIX=''

    [[ -d .venv ]] && PREFIX='.venv/bin/'

    ${PREFIX}python -m flit publish
    ```

### docs_preview
`docs_preview.sh` serves your project documentation in your local machine in *editable* mode, so you can follow your development seeing the final result at the same time.

??? example
    ```shell title="docs_preview.sh" linenums="1"
    #!/usr/bin/env bash

    PREFIX=''

    [[ -d .venv ]] && PREFIX='.venv/bin/'

    [[ -d docs ]] ||  ${PREFIX}python -m mkdocs new .

    ${PREFIX}python -m mkdocs serve
    ```

### docs_publish

`docs_publish.sh` is responsible for publishing your Python project documentation and hosting it on [GitHub Pages](https://pages.github.com/).

??? example
    ```shell title="docs_publish.sh" linenums="1"
    #!/usr/bin/env bash

    PREFIX=''

    [[ -z "$GITHUB_ACTIONS" ]] || ${PREFIX}mkdocs gh-deploy --force
    ```

### Makefile
I use a `Makefile` as an entry point for all the scripts in one place. makes things neat and tidy. Leave in the `root` of the project:

```shell
/scripts $ cd .. && touch Makefile
```

??? example
    ```Makefile title="Makefile" linenums="1"
    .PHONY: bootstrap format test docs

    VPATH = perf_py_project:tests

    bootstrap:
    	bash scripts/bootstrap.sh

    format:
    	bash scripts/format.sh

    test:
    	bash scripts/test.sh

    docs:
    	bash scripts/docs_preview.sh
    ```

You may notice that the `Makefile` has only 4 scripts. I publish the package and documentation as part of the CI/CD using GitHub Actions only, so I see no reason to have entry points for them in the `Makefile`.

Now that we have all scripts and the Makefile, let's bootstrap the project!

```shell
$ make bootstrap
### omitted output above this line ###
Config file pyproject.toml does not exist
make: *** [Makefile:4: bootstrap] Error 1
```

We got an error because the config file is missing. In the next text, we'll discuss what got wrong and continue with the setup. I hope you've made it this far, so I can say that at the end of part II I'm going to give you a shortcut to putting together a project like this without blowing your mind in 2 minutes or less.


[^1]: [Shell](https://en.wikipedia.org/wiki/Shell_(computing)) is a computer program that exposes an operating system's services to a human user or other programs.
[^2]: In computing, a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) is the character sequence consisting of the characters number sign and exclamation mark (#!) at the beginning of a script.