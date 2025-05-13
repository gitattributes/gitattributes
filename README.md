# A Collection of Useful .gitattributes Templates

Similarly to the [`.gitignore` Templates][gt], we're trying to build
templates for `.gitattributes`.

`Common.gitattributes` contains general exclusions that may apply to any project.
Consider including them if they are applicable to your project.

## Usage

For more information on gitattributes: [gitattributes(5)][g5] and for
Github-specific grammar: [Linguist docs][gh]

You can use [this](https://richienb.github.io/gitattributes-generator) or
[this](https://gitattributes.com/) handy dandy generator to generate your
gitattributes files on the fly based on files inside of this repository.

## CI step

To check if all files have a corresponding rule in .gitattributes, this script
can be used:

```sh
missing_attributes=$(git ls-files | git check-attr -a --stdin | grep 'text: auto' || printf '\n')

if [ -n "$missing_attributes" ]; then
  printf '%s\n%s\n' '.gitattributes rule missing for the following files:' "$missing_attributes"
else
  printf '%s\n' 'All files have a corresponding rule in .gitattributes'
fi
```

You can also use the checked-in `./check.sh` which has more features.
Run `./check.sh --help` for the available options.

## Contributing

Please contribute by [forking][fk] and sending a [pull request][pr].

Also **please** only modify **one file** per commit. This'll
make merging easier for everyone.

[gt]: https://github.com/github/gitignore
[fk]: http://help.github.com/forking/
[pr]: http://help.github.com/pull-requests/
[g5]: https://www.git-scm.com/docs/gitattributes
[gh]: https://github.com/github-linguist/linguist/blob/master/docs/overrides.md
