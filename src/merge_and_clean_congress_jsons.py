import os
from pathlib import Path

import pandas as pd

BIOGUIDES_PATH = (
    Path(os.path.abspath(__file__)).parent.parent
    / "data"
    / "BioguideProfiles"  # .parent
)

print(BIOGUIDES_PATH)

dfs = [pd.read_json(x, lines=True) for x in BIOGUIDES_PATH.glob("*.json")]
temp = pd.concat(dfs, ignore_index=True)

del dfs

temp = temp.loc[temp.apply(lambda x: len(x.jobPositions), axis=1) != 0]
#  ^ everyone that this step removes is a 1700s guy with basically no info
temp["congresses"] = temp.jobPositions.apply(
    lambda jobPositions: (
        sorted(
            [
                y["congressAffiliation"]["congress"]["congressNumber"]
                for y in jobPositions
                if "congress" in y["congressAffiliation"].keys()
            ]
        )
        if jobPositions != []
        else []
    )
)

str12395 = (
    "a Senator from Nebraska; born in Nebraska City, Nebr., August 19, 1964; graduated"
    " Westside High School, Omaha, Nebr., 1982; B.A., biology, University of Chicago,"
    " 1986; M.B.A., marketing and finance, University of Chicago, 1991; online"
    " brokerage firm president and chief operating officer; co-owner of Chicago Cubs"
    " baseball team; unsuccessful candidate for the United States Senate in 2006;"
    " governor of Nebraska 2015-2023; appointed as a Republican to the United States"
    " Senate on January 12, 2023, to fill the vacancy caused by the resignation of"
    " Benjamin Sasse; took the oath of office on January 23, 2023."
)
temp.loc[12395, "profileText"] = str12395

temp.to_json(BIOGUIDES_PATH.parent / "congress-bios.json")
