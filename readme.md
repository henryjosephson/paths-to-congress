trying to reproduce https://www.nytimes.com/interactive/2019/01/26/opinion/sunday/paths-to-congress.html

## Usage

I'm not uploading the data to github, because it would be too big.

Luckily, you can download and clean the data I'm using by `cd`ing to the project root (if you're reading this, you're probably already there), then running `bash src/process_data/setup_data.sh`.

From there, you can then open `main.html` with your favorite live server extension (I like [this one](https://open-vsx.org/extension/ms-vscode/live-server)) and you're all set.

## todos:

- [ ] rearrange dots for better spacing
- [ ] add background lines
- [ ]  make it so that when you hover over a path, you highlight all the (labeled) nodes that the path goes through 
- [ ] add invisible control nodes to reduce overlap
- [ ] give all the democrats positive offsets and the republicans negative offsets to make the sorting look nicer at each node
- [ ] get the paths to actually center at each node
- [ ] decrease spacing so it doesn't take up the entire screen
- [ ] drastically decrease path thickness
- [x] make circle size grow dynamically with the number of paths that go through it
- [x]  make it so that there's a `house` end node and a `senate` end node
- [ ] add a dropdown menu to let you choose a box