import pandas as pd
import utils

bios = pd.read_json("../../data/processed/congress-bios.json")
recentBios = bios.loc[
    [
        any(session in x for session in range(100, 119))
        for x in bios.congresses.to_list()
    ]
]

recentBios = recentBios[
    [
        "usCongressBioId",
        "givenName",
        "familyName",
        "unaccentedGivenName",
        "unaccentedFamilyName",
        "congresses",
        "profileText",
        "jobPositions",
    ]
]

del bios


def getParty(x):
    return x["congressAffiliation"]["partyAffiliation"][0]["party"]["name"][0]


temp = recentBios.loc[:, "jobPositions"].apply(
    lambda x: {
        y["congressAffiliation"]["congress"]["congressNumber"]: getParty(y)
        for y in x
        if y["congressAffiliation"]["congress"]["congressNumber"] > 99
    }
)

recentBios.loc[:, "parties"] = pd.DataFrame(
    {
        "empties": temp.apply(
            lambda x: {y: None for y in range(100, 119) if y not in x.keys()}
        ),
        "parties": temp,
    }
).apply(lambda row: dict(sorted({**row["parties"], **row["empties"]}.items())), axis=1)

temp = recentBios.loc[:, "jobPositions"].apply(
    lambda x: {
        y["congressAffiliation"]["congress"]["congressNumber"]: y["job"]["name"]
        for y in x
        if y["congressAffiliation"]["congress"]["congressNumber"] > 99
    }
)

recentBios.loc[:, "jobs"] = pd.DataFrame(
    {
        "empties": temp.apply(
            lambda x: {y: None for y in range(100, 119) if y not in x.keys()}
        ),
        "jobPositions": temp,
    }
).apply(
    lambda row: dict(sorted({**row["jobPositions"], **row["empties"]}.items())), axis=1
)


def get_state_abbrev(text):
    for state in utils.state_list:
        if state.lower() in text.lower():
            return utils.state_dict[state]

    return None


recentBios.loc[:, "state"] = recentBios.profileText.apply(
    lambda x: get_state_abbrev(x.split(";")[0])
)


# some corrections I'd made when I was working with the 118th congress manually.
# I'm sure similar corrections have to be made for the other congresses I'm
# working with, but I don't have the time to do that all now.abs

for idx in [11757, 9656, 2107]:
    recentBios.loc[idx, "profileText"] = recentBios.loc[idx, "profileText"].replace(
        "a Representative from", "a Senator and a Representative from"
    )

for col in ["unaccentedFamilyName", "unaccentedGivenName"]:
    recentBios[col] = recentBios[col].str.replace(r"[^a-zA-Z -]", "", regex=True)

recentBios.to_json("../../data/processed/temp-bios-for-claude.json", orient="index")
