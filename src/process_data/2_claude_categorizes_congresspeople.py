import json
import re
import time

import pandas as pd
import utils
from anthropic import Anthropic
from anthropic.types.beta.message_create_params import (
    MessageCreateParamsNonStreaming,
)
from anthropic.types.beta.messages.batch_create_params import Request
from dotenv import load_dotenv

load_dotenv()

client = Anthropic()


def load_bios():
    df = pd.read_json("../../data/processed/temp-bios-for-claude.json", index_col=0)
    return df


recentBios = load_bios()


def process_bios():
    message_batch = client.beta.messages.batches.create(
        requests=[
            Request(
                custom_id=f"{i}",
                params=MessageCreateParamsNonStreaming(
                    model="claude-3-5-sonnet-20241022",
                    max_tokens=512,
                    temperature=0.1,
                    system=utils.SYSTEM_PROMPT,
                    messages=[
                        {
                            "role": "user",
                            "content": [
                                {
                                    "type": "text",
                                    "text": utils.KEYS_AND_EXPLANATIONS,
                                },
                                {
                                    "type": "text",
                                    "text": "Here's the biography:\n\n"
                                    + x["profileText"],
                                },
                            ],
                        },
                        {
                            "role": "assistant",
                            "content": [
                                {
                                    "type": "text",
                                    "text": '{"communityCollege":',
                                },
                            ],
                        },
                    ],
                ),
            )
            for i, x in recentBios.iterrows()
        ]
    )
    return message_batch.id


batch_id = process_bios()


while True:
    message_batch = client.beta.messages.batches.retrieve(batch_id)
    if message_batch.processing_status == "ended":
        break

    print(f"Batch {batch_id} is still processing...")
    time.sleep(60)
print(message_batch)


def remove_comments(text):
    pattern = r"(\\|#).*\n"
    text = re.sub(pattern, "", text)

    return text


flags = []

for result in client.beta.messages.batches.results(batch_id):
    flags.append(
        json.loads(
            '{"communityCollege": '
            + remove_comments(result.result.message.content[0].text)
        )
    )

df = pd.merge(
    recentBios,
    pd.DataFrame(flags, index=recentBios.index),
    left_index=True,
    right_index=True,
)

df.to_json("../../data/processed/processed-bios.json", orient="index")
