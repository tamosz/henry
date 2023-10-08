import requests
from dotenv import load_dotenv
import os
import discord

load_dotenv()

APP_ID = os.getenv('APP_ID')
SERVER_ID = os.getenv('SERVER_ID')
BOT_TOKEN = os.getenv('BOT_TOKEN')

url = f"https://discord.com/api/v10/applications/{APP_ID}/guilds/{SERVER_ID}/commands"

json = [{"name": "asdf", "description": "hi mom", "options": []}]


response = requests.put(url, headers={"Authorization": f"Bot {BOT_TOKEN}"}, json=json)

