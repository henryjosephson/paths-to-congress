trying to reproduce https://www.nytimes.com/interactive/2019/01/26/opinion/sunday/paths-to-congress.html

## Usage

I'm not uploading the data to github, because it would be too big. Plus, I made Claude do most of the heavy lifting (for around $5), so there will probably be a bit of noise if you try to exactly re-run my analysis scripts. 

You can do either by running `bash src/process_data/setup_data.sh` and following the instructions.

Once `processed-bios.json` exists in `data/processed/`, you can then open `main.html` with your favorite live server extension (I like [this one](https://open-vsx.org/extension/ms-vscode/live-server)) and you're all set.

## todos:

- [ ] move labels for visibility
- [ ] rearrange dots for better spacing (ongoing)
- [ ] add background lines
- [ ] let you search by individual, party, state
- [ ] add writeup (sidescrolling above)
