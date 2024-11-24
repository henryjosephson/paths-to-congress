trying to reproduce https://www.nytimes.com/interactive/2019/01/26/opinion/sunday/paths-to-congress.html

## Usage

I'm not uploading the data to github, because it would be too big.

Luckily, you can download and clean the data I'm using by `cd`ing to the project root (if you're reading this, you're probably already there), then running `bash src/process_data/setup_data.sh`.

From there, you can then open `main.html` with your favorite live server extension (I like [this one](https://open-vsx.org/extension/ms-vscode/live-server)) and you're all set.

## todos:

- [x] make circle size grow dynamically with the number of paths that go through it
- [x]  make it so that there's a `house` end node and a `senate` end node
- [ ] rearrange dots for better spacing (ongoing)
- [ ] add background lines
- [ ]  make it so that when you hover over a path, you highlight all the (labeled) nodes that the path goes through 
  - [ ] probably means making all extant paths dimmer?
- [ ] add invisible control nodes ßto reduce path overlap
- [ ] give all the democrats positive offsets and the republicans negative offsets to make the sorting look nicer at each node
- [ ] get the paths to actually center at each node (this might have to be manual-er in final product — e.g. `customPublicCollegeCirclePlacement`)
- [ ] decrease spacing and path thickness so full version doesn't take up the entire screen 
- [ ] let you search by individual, party, state
  
- [ ] build pipeline to let claude parse bios into the relevant json format (important for going through the thousands of congresspeople from prev years)

