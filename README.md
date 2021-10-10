# A Collection of Useful .gitattributes Templates

Similarly to the [`.gitignore` Templates][gt], we're trying to build
templates for `.gitattributes`.

`Common.gitattributes` contains general exclusions that may apply to any project.
Consider including them if they are applicable to your project.

You can use [this handy dandy generator](https://richienb.github.io/gitattributes-generator) to generate your gitattributes files on the fly based on files inside of this repository.

## CI step

To check if all files have a corresponding rule in .gitattributes, this script can be used:

```sh
missing_attributes=$(git ls-files | git check-attr -a --stdin | grep "text: auto")
if [[ "$missing_attributes" ]]; then
  echo ".gitattributes rule missing for the following files:";
  echo "$missing_attributes";
else
  echo "All files have a corresponding rule in .gitattributes";
fi
```

## Contributing

Please contribute by [forking][fk] and sending a [pull request][pr].

Also **please** only modify **one file** per commit. This'll
make merging easier for everyone.

For more information on gitattributes: [gitattributes(5)][g5] and for Github-specific grammar: [Linguist docs][gh]

[gt]: https://github.com/github/gitignore
[fk]: http://help.github.com/forking/
[pr]: http://help.github.com/pull-requests/
[g5]: https://www.git-scm.com/docs/gitattributes
[gh]: https://www.rubydoc.info/github/github/linguist
