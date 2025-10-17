import requests

model_url = r"https://tinyurl.com/y566f9a2"
response = requests.get(model_url)
if response.status_code == 200:
    with open("training_output.gif", "wb") as f:
        f.write(response.content)
else:
    raise Exception(f"Failed to download, status code: {response.status_code}")
