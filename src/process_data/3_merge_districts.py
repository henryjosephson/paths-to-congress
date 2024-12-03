from datetime import datetime
from math import floor

import pandas as pd
import utils


def get_congress_from_term_dates(term_dict):
    start_date = datetime.strptime(term_dict["start"], "%Y-%m-%d")

    reference_congress = 74
    reference_date = datetime(1935, 1, 3)

    years_difference = (start_date - reference_date).days / 365.25
    congress_difference = floor(years_difference / 2)

    return reference_congress + congress_difference


processed = pd.read_json("../../data/processed/processed-bios.json").T

currentLegs = pd.read_json(
    "https://theunitedstates.io/congress-legislators/legislators-current.json"
)
historicalLegs = pd.read_json(
    "https://theunitedstates.io/congress-legislators/legislators-historical.json"
)

for df in [currentLegs, historicalLegs]:
    df.loc[:, "district"] = df.loc[:, "terms"].apply(
        lambda terms: {
            get_congress_from_term_dates(term): (
                term["district"] if "district" in term else term["state"]
            )
            for term in terms
        }
    )

df = pd.concat((currentLegs, historicalLegs))

temp = df.loc[:, "district"]

df["district"] = (
    pd.DataFrame(
        {
            "empties": df["district"].apply(
                lambda x: {y: None for y in range(100, 119) if y not in x.keys()}
            ),
            "district": df.loc[:, "district"],
        }
    )
    .apply(
        lambda row: dict(sorted({**row["district"], **row["empties"]}.items())), axis=1
    )
    .apply(lambda row: {key: row[key] for key in row.keys() if key > 99})
)

df["usCongressBioId"] = df["id"].apply(lambda x: x["bioguide"])

df = df[
    ~df["terms"].apply(
        lambda row: any(
            x["state"] for x in row if x["state"] not in utils.state_dict.values()
        )
    )
]

pd.merge(
    processed,
    df[["usCongressBioId", "district"]],
    how="left",
).to_json("../../data/processed/processed-bios.json", orient="index")
