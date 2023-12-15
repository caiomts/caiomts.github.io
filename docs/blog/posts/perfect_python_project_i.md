---
date: 2023-05-14
authors:
  - caiomts
categories:
  - Python projects
tags:
  - pyenv
  - GNU Make
  - Bash 
---

# How I set-up my Python Projects

There are no formal rules on how to setting up a Python project. Here I'll show you my very opinionated way of how to set up a python project. I try to follow the community standards and the Python tutorial as much as possivel (stands on the shoulders of giants). You can also find an 'official' basic Python tutorial on [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/).

<!-- more -->

To follow this tutorial in full you need to meet the requirements below.

## Requirements
- pyenv
- GNU Make
- Bash

!!! tip
    If you're a Windows user, my suggestion is to install [WSL 2](https://learn.microsoft.com/en-us/windows/wsl/about). With it you get a GNU/Linux environment. Microsoft itself suggests installing Python with WSL for some users.

    Within your WSL Shell you can follow this tutorial seamlessly.

### pyenv
[pyenv](https://github.com/pyenv/pyenv) is a simple Python version Manager.
Even though it's recomended to keep your Python version up to date, one day in your python journey you'll get caught up in needing to use different versions of it and then you'll realize that pyenv will make your life much easier.

!!! warning
    pyenv doesn't support Windows, but you can use it within WSL.


### GNU Make
[GNU Make](https://www.gnu.org/software/make/) is a tool which controls the generation of executables and other non-source files of a program. I use it to create entry points to organize commands and scripts that we use a lot during the development process like running tests, generating docs, running linters, etc.


## Setting up the folders

Now that you already have your setup up and running. Let's create the smallest folder structure you need for you project.

Let's call the project *perf_py_project*.

```shell
$ mkdir -p perf_py_project/{perf_py_project,scripts,tests}
```

`-p` is the shortcut of `--parents`. Let's see how the folder structure looks like.
```shell
$ tree -a
.
└── perf_py_project
    ├── perf_py_project
    ├── scripts
    └── tests

```

The first folder is the default GitHub folder where we put all github actions files. The second is where you will save your own project, the third the scripts to automate some routines and the last one your tests.

## Python setup

inside the root folder we can configure Python version and environment.

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


Let's take a look for the sake of sanity.

```shell hl_lines="1"
$ . .venv/bin/activate
(.venv) $ python -V
Python 3.11.3
```

The one highlighted above is the command you need to call every time you want to activate your project environment :rolling_eyes:. Nobody likes to do the same thing over and over and what moves a good programmer is the laziness of doing something manually that can be done programmatically or manually abbreviated.

## Scripts and Makefile

During a Python project, you'll almost certainly be running a bunch of commands over and over again, so it's a good compromise to have some scripts running those commands automatically for you.

The shortest list of scripts I always have is (We'll go through each one in a bit):

- bootstrap.sh
- format.sh
- test.sh
- publish.sh
- docs_preview.sh
- docs_publish.sh

This list is not fixed and you can add new scripts or not use them all if you feel so.

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
`publish.sh` is responsible for publishing your Python project as a package on [PyPI](https://pypi.org/). You only need this script if you wish to publish your project as a python package.


??? example
    ```shell title="publish.sh" linenums="1"
    #!/usr/bin/env bash

    set -e

    PREFIX=''

    [[ -d .venv ]] && PREFIX='.venv/bin/'

    ${PREFIX}python -m flit publish
    ```

### docs_preview
`docs_preview.sh` serves your project documentation in your local machine in *editable* mode, so you can follow your development seeing the final result at the same time. Documentation is a very important part of any project. I really like `Mkdocs - material` to generate my documentation, but there are other options. In the simplistic way you can simply document your project as a part of your `README.md`. Again, you only need this script if you are willing to publish your documentation using `Mkdocs` package.

??? example
    ```shell title="docs_preview.sh" linenums="1"
    #!/usr/bin/env bash

    PREFIX=''

    [[ -d .venv ]] && PREFIX='.venv/bin/'

    [[ -d docs ]] ||  ${PREFIX}python -m mkdocs new .

    ${PREFIX}python -m mkdocs serve
    ```

### docs_publish

`docs_publish.sh` is responsible for publishing your Python project documentation and hosting it on [GitHub Pages](https://pages.github.com/). This script is linked to the one above, so it only works if you decided to publish or document it this way.

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

We got an error because the ` pyproject.toml` file is missing, so let's create it.

### pyproject.toml

```shell hl_lines="2"
$ . .venv/bin/activate
(.venv) $ python -m flit init
Module name [perf_py_project]:
Author: <put your name here>
Author email: <same with your email>
Home page: https://<your GitHub name>.github.io/perf_py_project/
Choose a license (see http://choosealicense.com/ for more info)
1. MIT - simple and permissive
2. Apache - explicitly grants patent rights
3. GPL - ensures that code based on this is shared with the same terms
4. Skip - choose a license later
Enter 1-4 [4]: 4

Written pyproject.toml; edit that file to add optional extra info.
```

The highlight above shows that I use [`flit`](https://flit.pypa.io/en/latest/) to create distribution packages for the project. There is a list of other tools, some of them with a bunch of other features. I like `flit` as good compromise between simplicity and getting things done, but you can choose other tools, Python Tutorial on [Packaging Python Projects](https://packaging.python.org/en/latest/tutorials/packaging-projects/#creating-pyproject-toml) has a non-exhaustive list. Be aware that I called flit in the scripts, so if you pick up another tool, make sure you change the scripts as well. 

Let's take a look on the new file pyproject.toml.

```shell
$ cat pyproject.toml 
[build-system]
requires = ["flit_core >=3.2,<4"]
build-backend = "flit_core.buildapi"

[project]
name = "perf_py_project"
authors = [{name = "Your Name", email = "Your e-mail"}]
dynamic = ["version", "description"]

[project.urls]
Home = "https://<your GitHub name>.github.io/perf_py_project/"

```

The `pyproject.toml` that was automatically generated by `flit` is very basic and you need to add a lot more information. I'll keep it as simple as possible but you can see a better presentation of the sections [here](https://flit.pypa.io/en/latest/pyproject_toml.html#build-system-section).

You should be very careful with `required-python`, `dependencies` and `[project.optional-dependencies]`. The example below does not have `dependencies`, as it depends on the project you are developing, nor does it have `required-python`. However, you see the main optional dependencies that I normally start any Python project with and also some configuration. Versions are dated, so you may need to update them.

Whenever you need a new dependency in your project, you need to update this file and initialize the project again. This is why the script is so useful, as long as you keep your `pyproject.toml` up to date, you can configure and install the project with a `make bootstrap` command.

??? example
    ```toml title="pyproject.toml" linenums="1"
    [build-system]
    requires = ["flit_core >=3.2,<4"]
    build-backend = "flit_core.buildapi"

    [project]
    name = "perf_py_project"
    authors = [{name = "Your Name", email = "Your e-mail"}]
    readme = "README.md"
    requires-python = ""
    dynamic = ["version", "description"]
    dependencies = [
 
    ]

    [project.urls]
    Home = "https://<your GitHub name>.github.io/perf_py_project/"
    Source = "https://github.com/<your GitHub name>/perf_py_project"

    [project.scripts]

    [project.optional-dependencies]
    test = [
        "pytest >=7.2.1, <7.3",
        "pytest-cov >=4.0.0, <4.1",
    ]

    docs = [
    	"mkdocs-material >=9.1.3, <9.2",
        "mkdocstrings[python] >=0.20, <0.21",
    ]

    dev = [
    	"black >=23.1, <23.2",
    	"flake8 >=6.0, <6.1",
    	"isort >=5.12, <5.13",
        "pydocstyle[toml] >=6.3.0, <6.4",
    ]

    [tool.black]
    line-length = 79
    target-version = ["py311"]
    skip-string-normalization = true

    [tool.isort]
    profile = "black"

    
    [tool.pydocstyle]
    inherit = false
    ignore = "D100,D107,D213,D203,D405,D406,D407,D413"
    ```

Now let's focus in other files you need in your python project.

## Files

Below you see a list of basic files you need in the root folder. I'll brefly explain each one of them and give you examples or links where you can create them by yourself.

- ~~Makefile~~
- README.md
- LICENSE
- ~~pyproject.toml~~
- mkdocs.yml

### README

`README.md` is a description of your project. It can be a small documentation that contains links and other important information like requirements, licenses, contribution guidelines, etc. Or it can also contain your tutorials and documentation on how to use your python program.

You can read more [About READMEs](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes) in GitHub.


### LICENSE

`LICENSE` is a must in open source projects. Here you can [choose a license](https://choosealicense.com/).

### mkdocs.yml

It is the configuration file related to the `Mkdocs` documentation library. If you choose to document your project using it. You need to have this configuration file in your root folder, otherwise it is not necessary. For those who want to use `MKdocs`, I suggest starting [here](https://www.mkdocs.org/getting-started/) or going directly to the more famous implementation [Material for Mkdocs](https://squidfunk. github.io/mkdocs-material/).

## Project Folder

To be able to package your project, use it as a package, or initialize it using flit, you need to have a `__init__.py` in your project folder. To create it, simply:

```bash
$ touch  perf_py_project/__init__.py
```

After creating it you need to put a docstring on top of it with a short description of you project, to be able to run the flit package.

```bash
$ echo '"""This is my perfect project."""' >>  perf_py_project/__init__.py
```

Before running your `bootstrap.sh` again, let's create two more files that will be useful in your development process.

## Test folder

Before running your test suite you also need an `__init__.py` in your `tests` folder. This one may be completely empty. Now you can also create another empty file in your tests folder, but I'm sure it will come in handy once you start writing and running your test suite.

```bash
$ touch  tests/__init__.py tests/conftest.py
```

If you followed this tutorial until know you should have the following structure in your root folder:

```bash
$ tree
.
├── LICENSE
├── Makefile
├── README.md
├── your_project_name
│   └── __init__.py
├── pyproject.toml
├── scripts
│   ├── bootstrap.sh
│   ├── format.sh
│   ├── preview_docs.sh
│   ├── publish.sh
│   ├── publish_docs.sh
│   └── test.sh
└── test
    ├── __init__.py
    └── conftest.py
```

There are many more files and folders that your project can contain, depending on the complexity and goals you have. However, this is a good start. But if you find this process a bit boring and are asking whether you need to go through it every time you start a new Python project, the answer is yes, but you don't need to do it manually. You can automate this entire process using Python if you wish, or use other automations. I have [mine](https://github.com/caiomts/python_project_template) that will give you a much more complex project structure than this, but follow all the steps you learned here.


[^1]: [Shell](https://en.wikipedia.org/wiki/Shell_(computing)) is a computer program that exposes an operating system's services to a human user or other programs.
[^2]: In computing, a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) is the character sequence consisting of the characters number sign and exclamation mark (#!) at the beginning of a script.